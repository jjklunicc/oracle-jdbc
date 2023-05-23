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
	System.out.println("rank_ntile_list currentPage : " + currentPage);
	
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
	System.out.println("rank_ntile_list totalCnt : " + totalCnt);
	
	//마지막 페이지 구하기
	int rowPerPage = 10;
	int lastPage = totalCnt / rowPerPage;
	if(totalCnt % rowPerPage != 0){
		lastPage++;
	}
	
	//디버깅
	System.out.println("rank_ntile_list lastPage : " + lastPage);
	
	//페이지네이션 시작-끝
	int pagePerPage = 5;
	int startPage = (currentPage - 1) / pagePerPage * pagePerPage + 1;
	int endPage = startPage + pagePerPage - 1;
	if(endPage > lastPage){
		endPage = lastPage;
	}
	
	//디버깅
	System.out.println("rank_ntile_list startPage : " + startPage);
	System.out.println("rank_ntile_list endPage : " + endPage);
	
	//페이지 시작행-끝행
	int startRow = (currentPage - 1) * rowPerPage + 1;
	int endRow = startRow + rowPerPage - 1;
	if(endRow > totalCnt){
		endRow = totalCnt;
	}
	
	//디버깅
	System.out.println("rank_ntile_list startRow : " + startRow);
	System.out.println("rank_ntile_list endRow : " + endRow);
	
	//rank, ntile결과 쿼리
	String rnSql = "select 이름, 급여, 등급, 순위 from (select 이름, 급여, 등급, 순위, rownum rnum from (select first_name 이름, salary 급여, ntile(10) over(order by salary desc) 등급, rank() over(order by salary desc) 순위 from employees)) where rnum between ? and ?";
	PreparedStatement rnStmt = conn.prepareStatement(rnSql);
	
	//?값 세팅
	rnStmt.setInt(1, startRow);
	rnStmt.setInt(2, endRow);
	
	//실행 후 결과 저장
	ResultSet rnRs = rnStmt.executeQuery();
	ArrayList<HashMap<String, Object>> list = new ArrayList<>();
	while(rnRs.next()){
		HashMap<String, Object> m = new HashMap<>();
		m.put("이름", rnRs.getString("이름"));
		m.put("급여", rnRs.getInt("급여"));
		m.put("등급", rnRs.getInt("등급"));
		m.put("순위", rnRs.getInt("순위"));
		list.add(m);
	}
	
	//디버깅
	System.out.println("rank_ntile_list listSize : " + list.size());
%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>Rank Ntile List</title>
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
			<td>이름</td>
			<td>급여</td>
			<td>등급</td>
			<td>순위</td>
		</tr>
		<%
			for(HashMap<String, Object> m : list){
		%>
				<tr>
					<td><%=(String)m.get("이름") %></td>
					<td><%=(Integer)m.get("급여") %></td>
					<td><%=(Integer)m.get("등급") %></td>
					<td><%=(Integer)m.get("순위") %></td>
				</tr>
		<%
			}
		%>
	</table>
	<%
		if(startPage != 1){
	%>
			<a href="rank_ntile_list.jsp?currentPage=<%=startPage - pagePerPage %>">이전</a>
	<%
		}
	
		for(int i = startPage; i <= endPage; i++){
			String selected = i == currentPage ? "selected" : "";
	%>
			<a href="rank_ntile_list.jsp?currentPage=<%=i%>" class=<%=selected %>><%=i%></a>
	<%
		}
		if(endPage != lastPage){
	%>
			<a href="rank_ntile_list.jsp?currentPage=<%=endPage + 1 %>">다음</a>
	<%
		}
	%>
</body>
</html>