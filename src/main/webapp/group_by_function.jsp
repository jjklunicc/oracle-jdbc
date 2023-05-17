<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%
	//db연결을 위한 변수설정
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dburl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbuser = "hr";
	String dbpw = "1234";
	
	//db연결
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	//grouping sets를 가져오기 위한 쿼리
	String groupingSql = "select department_id 부서ID, job_id 직무ID, count(*) 부서인원 from employees group by grouping sets(department_id, job_id)";
	PreparedStatement groupingStmt = conn.prepareStatement(groupingSql);
	
	//실행후 값 저장
	ResultSet groupingRs = groupingStmt.executeQuery();
	ArrayList<HashMap<String, Object>> groupingList = new ArrayList<>();
	
	while(groupingRs.next()){
		HashMap<String, Object> m = new HashMap<>();
		m.put("부서ID", groupingRs.getInt("부서ID"));
		m.put("직무ID", groupingRs.getString("직무ID"));
		m.put("부서인원", groupingRs.getInt("부서인원"));
		groupingList.add(m);
	}
	
	//rollup한 결과를 가져오기 위한 쿼리
	String rollupSql = "select department_id 부서ID, job_id 직무ID, count(*) 부서인원 from employees group by rollup(department_id, job_id)";
	PreparedStatement rollupStmt = conn.prepareStatement(rollupSql);
	
	//실행후 값 저장
	ResultSet rollupRs = rollupStmt.executeQuery();
	ArrayList<HashMap<String, Object>> rollupList = new ArrayList<>();
	
	while(rollupRs.next()){
		HashMap<String, Object> m = new HashMap<>();
		m.put("부서ID", rollupRs.getInt("부서ID"));
		m.put("직무ID", rollupRs.getString("직무ID"));
		m.put("부서인원", rollupRs.getInt("부서인원"));
		rollupList.add(m);
	}
	
	//cube한 결과를 가져오기 위한 쿼리
	String cubeSql = "select department_id 부서ID, job_id 직무ID, count(*) 부서인원 from employees group by cube(department_id, job_id)";
	PreparedStatement cubeStmt = conn.prepareStatement(cubeSql);
	
	//실행후 값 저장
	ResultSet cubeRs = cubeStmt.executeQuery();
	ArrayList<HashMap<String, Object>> cubeList = new ArrayList<>();
	
	while(cubeRs.next()){
		HashMap<String, Object> m = new HashMap<>();
		m.put("부서ID", cubeRs.getInt("부서ID"));
		m.put("직무ID", cubeRs.getString("직무ID"));
		m.put("부서인원", cubeRs.getInt("부서인원"));
		cubeList.add(m);
	}
%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>Group by Function</title>
	<style>
		table, td{
			border: 1px solid #333333;
		}
		div{
			display: flex;
			justify-content:space-between;
			width: 1280px;
		}
	</style>
</head>
<body>
	<div>
		<table>
			<tr>
				<td colspan="3">grouping set</td>
			</tr>
			<tr>
				<td>부서ID</td>
				<td>직무ID</td>
				<td>부서인원</td>
			</tr>
			<%
				for(HashMap<String, Object> m : groupingList){
			%>
					<tr>
						<td><%=(Integer)m.get("부서ID") %></td>
						<td><%=(String)m.get("직무ID") %></td>
						<td><%=(Integer)m.get("부서인원") %></td>
					</tr>
			<%
				}
			%>
		</table>
		<table>
			<tr>
				<td colspan="3">rollup</td>
			</tr>
			<tr>
				<td>부서ID</td>
				<td>직무ID</td>
				<td>부서인원</td>
			</tr>
			<%
				for(HashMap<String, Object> m : rollupList){
			%>
					<tr>
						<td><%=(Integer)m.get("부서ID") %></td>
						<td><%=(String)m.get("직무ID") %></td>
						<td><%=(Integer)m.get("부서인원") %></td>
					</tr>
			<%
				}
			%>
		</table>
		<table>
			<tr>
				<td colspan="3">cube</td>
			</tr>
			<tr>
				<td>부서ID</td>
				<td>직무ID</td>
				<td>부서인원</td>
			</tr>
			<%
				for(HashMap<String, Object> m : cubeList){
			%>
					<tr>
						<td><%=(Integer)m.get("부서ID") %></td>
						<td><%=(String)m.get("직무ID") %></td>
						<td><%=(Integer)m.get("부서인원") %></td>
					</tr>
			<%
				}
			%>
		</table>
	</div>
</body>
</html>