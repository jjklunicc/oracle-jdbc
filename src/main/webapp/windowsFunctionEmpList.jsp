<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%
	//요청값 저장
	int currentPage = 1;
	if(request.getParameter("currentPage") != null
	&& !request.getParameter("currentPage").equals("")){
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	
	//요청값 디버깅
	System.out.println("windowFuctionEmpList currentPage : " + currentPage);
	
	//DB연결을 위한 변수 설정
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dburl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbuser = "hr";
	String dbpw = "1234";
	
	//db연결
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	//전체 개수를 구하기 위한 쿼리
	String cntSql = "select count(*) cnt from employees";
	PreparedStatement cntStmt = conn.prepareStatement(cntSql);
	ResultSet cntRs = cntStmt.executeQuery();
	int totalCnt = 0;
	if(cntRs.next()){
		totalCnt = cntRs.getInt("cnt");
	}
		
	//페이징을 위한 변수
	int rowPerPage = 10;
	int startRow = (currentPage - 1) * 10 + 1;
	int endRow = startRow + rowPerPage - 1;
	if(endRow > totalCnt){
		endRow = totalCnt;
	}
	
	System.out.println("windowFunctionEmpList startRow : " + startRow);
	System.out.println("windowFunctionEmpList endRow : " + endRow);
	
	//사원 데이터를 불러오는 쿼리
	String sql = "select employee_id, last_name, salary, 전체급여평균, 전체급여합계, 전체사원수, rnum from (select employee_id, last_name, salary, round(avg(salary) over()) 전체급여평균, sum(salary) over() 전체급여합계, count(*) over() 전체사원수, rownum rnum from employees) where rnum between ? and ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	System.out.println("windowFunctionEmpList query : " + stmt);
	stmt.setInt(1, startRow);
	stmt.setInt(2, endRow);
	
	//쿼리 실행 후 결과 저장
	ResultSet rs = stmt.executeQuery();
	ArrayList<HashMap<String, Object>> list = new ArrayList<>();
	while(rs.next()){
		HashMap<String, Object> m = new HashMap<>();
		m.put("직원ID", rs.getInt("employee_id"));
		m.put("이름", rs.getString("last_name"));
		m.put("연봉", rs.getInt("salary"));
		m.put("전체급여평균", rs.getInt("전체급여평균"));
		m.put("전체급여합계", rs.getInt("전체급여합계"));
		m.put("전체사원수", rs.getInt("전체사원수"));
		list.add(m);
	}

	//list개수 디버깅
	System.out.println("windowFunctionEmpList listSize : " + list.size());
	
	//페이지네이션을 위한 변수
	int totalPage = totalCnt / rowPerPage;
	if(totalCnt % rowPerPage != 0){
		totalPage++;
	}
	
	int pagePerPage = 10;
	int startPage = (currentPage - 1) / pagePerPage * pagePerPage + 1;
	int endPage = startPage + pagePerPage - 1;
	if(endPage > totalPage){
		endPage = totalPage;
	}
	
%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>Window Function EmpList</title>
	<style>
		table, td{
			border: 1px solid #333333;
		}
		a:visited{
			color: blue;
			text-decoration: underline;
		}
	</style>
</head>
<body>
	<table>
		<tr>
			<td>직원ID</td>
			<td>이름</td>
			<td>연봉</td>
			<td>전체급여평균</td>
			<td>전체급여합계</td>
			<td>전체사원수</td>
		</tr>
		<%
			for(HashMap<String, Object> m : list){
		%>
				<tr>
					<td><%=(Integer)m.get("직원ID") %></td>
					<td><%=(String)m.get("이름") %></td>
					<td><%=(Integer)m.get("연봉") %></td>
					<td><%=(Integer)m.get("전체급여평균") %></td>
					<td><%=(Integer)m.get("전체급여합계") %></td>
					<td><%=(Integer)m.get("전체사원수") %></td>
				</tr>
		<%
			}
		%>
	</table>
	<%
		if(startPage != 1){
	%>
			<a href="./windowsFunctionEmpList.jsp?currentPage=<%=startPage - pagePerPage%>">이전</a>
	<%
		}
	%>
	<%
		for(int i = startPage; i <= endPage; i++){
			
			if(i == currentPage){
	%>
				<span><%=i %></span>
	<%
			}else{
	%>
				<a href="./windowsFunctionEmpList.jsp?currentPage=<%=i %>"><%=i %></a>
	<%
			}
		}
	%>
	<%
		if(endPage != totalPage){
	%>
			<a href="./windowsFunctionEmpList.jsp?currentPage=<%=endPage + 1%>">다음</a>
	<%
		}
	%>
</body>
</html>