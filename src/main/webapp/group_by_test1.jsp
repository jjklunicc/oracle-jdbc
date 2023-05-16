<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
	/*
		select 
			department_id 부서ID, 
			count(*) 부서인원, sum(salary) 급여합계,
			round(avg(salary), 1) 급여평균,
			max(salary) 최대급여,
			min(salary) 최소급여 --5
		from employees --1
		where department_id is not null --2 where절은 group by절보다 실행순서가 우선 => 집계 결과에 대한 조건을 필터링할 수 없음. => group by 결과를 필터링하는 조건절 필요(having)
		group by department_id --3
		having count(*) > 1 -- 4
		order by count(*) desc; --6	
	*/
	
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
	
	//집계 데이터 불러오는 쿼리
	String sql = "select department_id 부서ID, count(*) 부서인원, sum(salary) 급여합계, round(avg(salary), 1) 급여평균, max(salary) 최대급여, min(salary) 최소급여 from employees where department_id is not null group by department_id having count(*) > 1 order by count(*) desc";
	PreparedStatement stmt = conn.prepareStatement(sql);
	
	//디버깅
	System.out.println(stmt);
	
	//쿼리 실행후 결과값 ArrayList<HashMap<String, Object>>에 저장
	ResultSet rs = stmt.executeQuery();
	ArrayList<HashMap<String, Object>> list = new ArrayList<>();
	while(rs.next()){
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("부서ID", rs.getInt("부서ID"));
		m.put("부서인원", rs.getInt("부서인원"));
		m.put("급여합계", rs.getInt("급여합계"));
		m.put("급여평균", rs.getDouble("급여평균"));
		m.put("최대급여", rs.getInt("최대급여"));
		m.put("최소급여", rs.getInt("최소급여"));
		list.add(m);
	}
	System.out.print(list);
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<style>
	table,td{
		border: 1px solid #333333;
		border-collapse: collapse;
		padding: 5px;
	}
</style>
</head>
<body>
	<h1>Employees table GROUP BY Test</h1>
	<table>
		<tr>
			<td>부서ID</td>
			<td>부서인원</td>
			<td>급여합계</td>
			<td>급여평균</td>
			<td>최대급여</td>
			<td>최소급여</td>
		</tr>
		<%
			for(HashMap<String, Object> m : list){
		%>
				<tr>
					<td><%=m.get("부서ID") %></td>
					<td><%=m.get("부서인원") %></td>
					<td><%=m.get("급여합계") %></td>
					<td><%=m.get("급여평균") %></td>
					<td><%=m.get("최대급여") %></td>
					<td><%=m.get("최소급여") %></td>
				</tr>
		<%
			}
		%>
	</table>
</body>
</html>