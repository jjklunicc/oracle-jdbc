<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
	int currentPage = 1;
	if(request.getParameter("currentPage") != null
	&& !request.getParameter("currentPage").equals("")){
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
		
	//db연결을 위한 변수설정
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dburl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbuser = "hr";
	String dbpw = "1234";
	
	//db연결
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	//디버깅
	System.out.println(conn);
	
	//전체 개수 구하는 쿼리
	int totalRow = 0;
	String totalRowSql = "select count(*) from employees";
	PreparedStatement totalRowStmt = conn.prepareStatement(totalRowSql);
	ResultSet totalRowRs = totalRowStmt.executeQuery();
	if(totalRowRs.next()){
		//인덱스로 가져올 수 있음.
		totalRow = totalRowRs.getInt(1);
	}
		
	int rowPerPage = 10;
	int beginRow = (currentPage - 1) * rowPerPage + 1;
 	int endRow = beginRow + rowPerPage - 1;
 	
 	if(endRow > totalRow){
 		endRow = totalRow;
 	}
	
	//쿼리문
	String sql = "select 번호, 이름, 이름첫글자, 연봉, 급여, 입사일자, 입사년도 from (select rownum 번호, last_name 이름, substr(last_name, 1, 1) 이름첫글자, salary 연봉, round(salary/12, 2) 급여, hire_date 입사일자, extract(year from hire_date) 입사년도 from employees) where 번호 between ? and ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	
	//?값 세팅
	stmt.setInt(1, beginRow);
	stmt.setInt(2, endRow);
	
	//디버깅
	System.out.println(stmt);
	
	ResultSet rs = stmt.executeQuery();
	ArrayList<HashMap<String, Object>> list = new ArrayList<>();
	while(rs.next()){
		HashMap<String, Object> m = new HashMap<>();
		m.put("번호", rs.getInt("번호"));
		m.put("이름", rs.getString("이름"));
		m.put("이름첫글자", rs.getString("이름첫글자"));
		m.put("연봉", rs.getInt("연봉"));
		m.put("급여", rs.getDouble("급여"));
		m.put("입사일자", rs.getString("입사일자"));
		m.put("입사년도", rs.getInt("입사년도"));
		list.add(m);
	}
	System.out.println(list.size());
%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>Insert title here</title>
</head>
<body>
	<table>
		<tr>
			<td>번호</td>
			<td>이름</td>
			<td>이름첫글자</td>
			<td>연봉</td>
			<td>급여</td>
			<td>입사일자</td>
			<td>입사년도</td>
		</tr>
		<%
			for(HashMap<String, Object> m : list){
		%>
				<tr>
					<td><%=(Integer)m.get("번호") %></td>
					<td><%=m.get("이름") %></td>
					<td><%=m.get("이름첫글자") %></td>
					<td><%=(Integer)m.get("연봉") %></td>
					<td><%=(Double)m.get("급여") %></td>
					<td><%=m.get("입사일자") %></td>
					<td><%=(Integer)m.get("입사년도") %></td>
				</tr>
		<%
			}
		%>
	</table>
	
	<%
		//페이지 네비게이션 페이징
		int lastPage = totalRow / rowPerPage;
		if(totalRow % rowPerPage != 0){
			lastPage++;
		}
		int pagePerPage = 10;
		int minPage = (currentPage - 1) / pagePerPage * pagePerPage + 1;
		int maxPage = minPage + pagePerPage - 1;
		if(maxPage > lastPage){
			maxPage = lastPage;
		}
		
		if(minPage > 1){
	%>
		<a href="<%=request.getContextPath() %>/functionEmpList.jsp?currentPage=<%=minPage - 1%>">이전</a>
	<%	
		}
		for(int i = minPage; i <= maxPage; i++){
			
			if(i == currentPage){
	%>
				<span><%=i %></span>
	<%
			}else{
	%>
			<a href="<%=request.getContextPath() %>/functionEmpList.jsp?currentPage=<%=i %>"><%=i %></a>
	<%
			}
		}
		if(maxPage != lastPage){
	%>
			<a href="<%=request.getContextPath() %>/functionEmpList.jsp?currentPage=<%=maxPage + 1%>">다음</a>
	<%
		}
	%>
</body>
</html>