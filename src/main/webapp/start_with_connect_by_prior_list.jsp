<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
	//요청값 저장
	int currentPage = 1;
	if(request.getParameter("currentPage") != null
	&& !request.getParameter("currentPage").equals("")){
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	
	//디버깅
	System.out.println("start_with_connect_by_prior_list currentPage : " + currentPage);
	
	//db연결을 위한 변수설정
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dburl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbuser = "hr";
	String dbpw = "1234";
	
	//db연결
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	//전체 개수를 불러오기 위한 쿼리
	String cntSql = "select count(*) cnt from employees";
	PreparedStatement cntStmt = conn.prepareStatement(cntSql);
	ResultSet cntRs = cntStmt.executeQuery();
	
	//전체 개수를 저장
	int totalCnt = 0;
	if(cntRs.next()){
		totalCnt = cntRs.getInt("cnt");	
	}
	
	//디버깅
	System.out.println("start_with_connect_by_prior_list totalCnt : " + totalCnt);
	
	//마지막 페이지 구하기
	int rowPerPage = 10;
	int lastPage = totalCnt / rowPerPage;
	if(totalCnt % rowPerPage != 0){
		lastPage++;
	}
	
	//디버깅
	System.out.println("start_with_connect_by_prior_list lastPage : " + lastPage);
	
	//페이지네이션 시작-끝
	int pagePerPage = 5;
	int startPage = (currentPage - 1) / pagePerPage * pagePerPage + 1;
	int endPage = startPage + pagePerPage - 1;
	if(endPage > lastPage){
		endPage = lastPage;
	}
	
	//디버깅
	System.out.println("start_with_connect_by_prior_list startPage : " + startPage);
	System.out.println("start_with_connect_by_prior_list endPage : " + endPage);
	
	//페이지 시작행-끝행
	int startRow = (currentPage - 1) * rowPerPage + 1;
	int endRow = startRow + rowPerPage - 1;
	if(endRow > totalCnt){
		endRow = totalCnt;
	}
	
	//디버깅
	System.out.println("start_with_connect_by_prior_list startRow : " + startRow);
	System.out.println("start_with_connect_by_prior_list endRow : " + endRow);

	//start_with, connect_by_prior한 결과를 가져오는 쿼리
	String sql = "select 레벨, 이름, 매니저, 계층 from (select 레벨, 이름, 매니저, 계층, rownum rnum  from (select level 레벨, first_name 이름, manager_id 매니저, sys_connect_by_path(first_name, '-') 계층 from employees start with manager_id is null connect by prior employee_id = manager_id)) where rnum between ? and ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	
	//?값 세팅
	stmt.setInt(1, startRow);
	stmt.setInt(2, endRow);
	
	//실행 후 결과 저장
	ResultSet rs = stmt.executeQuery();
	ArrayList<HashMap<String, Object>> list = new ArrayList<>();
	while(rs.next()){
		HashMap<String, Object> m = new HashMap<>();
		m.put("레벨", rs.getInt("레벨"));
		m.put("이름", rs.getString("이름"));
		m.put("매니저", rs.getInt("매니저"));
		m.put("계층", rs.getString("계층"));
		list.add(m);
	}
	
	//디버깅
	System.out.println("start_with_connect_by_prior_list listSize : " + list.size());
%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>Start With Connect By Prior List</title>
	<style>
		table, td{
			border: 1px solid #333333;
		}
		a{
			color: blue;
		}
		.selected{
			color: red;
		}
	</style>
</head>
<body>
	<table>
		<tr>
			<td>레벨</td>
			<td>이름</td>
			<td>매니저</td>
			<td>계층</td>
		</tr>
		<%
			for(HashMap<String, Object> m : list){
		%>
				<tr>
					<td><%=(Integer)m.get("레벨") %></td>
					<td><%=(String)m.get("이름") %></td>
					<td><%=(Integer)m.get("매니저") %></td>
					<td><%=(String)m.get("계층") %></td>
				</tr>
		<%
			}
		%>
	</table>
	<%
		if(startPage != 1){
	%>
			<a href="start_with_connect_by_prior_list.jsp?currentPage=<%=startPage - pagePerPage %>">이전</a>
	<%
		}
	
		for(int i = startPage; i <= endPage; i++){
			String selected = i == currentPage ? "selected" : "";
	%>
			<a href="start_with_connect_by_prior_list.jsp?currentPage=<%=i%>" class=<%=selected %>><%=i%></a>
	<%
		}
		if(endPage != lastPage){
	%>
			<a href="start_with_connect_by_prior_list.jsp?currentPage=<%=endPage + 1 %>">다음</a>
	<%
		}
	%>
</body>
</html>