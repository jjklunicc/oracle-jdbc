<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
	//db연결을 위한 변수설정
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dburl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbuser = "gdj66";
	String dbpw = "1234";
	
	//db연결
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	//nvl함수 사용하는 쿼리
	String nvlSql = "select 이름, nvl(일분기, 0) 일분기 from 실적";
	PreparedStatement nvlStmt = conn.prepareStatement(nvlSql);
	
	//쿼리 실행 후 결과값 저장
	ResultSet nvlRs = nvlStmt.executeQuery();
	ArrayList<HashMap<String, Object>> nvlList = new ArrayList<>();
	while(nvlRs.next()){
		HashMap<String, Object> m = new HashMap<>();
		m.put("이름", nvlRs.getString("이름"));
		m.put("일분기", nvlRs.getInt("일분기"));
		nvlList.add(m);
	}
	
	//nvl2함수 사용하는 쿼리
	String nvl2Sql = "select 이름, nvl2(일분기, 'success', 'fail') 일분기 from 실적";
	PreparedStatement nvl2Stmt = conn.prepareStatement(nvl2Sql);
	
	//쿼리 실행 후 결과값 저장
	ResultSet nvl2Rs = nvl2Stmt.executeQuery();
	ArrayList<HashMap<String, Object>> nvl2List = new ArrayList<>();
	while(nvl2Rs.next()){
		HashMap<String, Object> m = new HashMap<>();
		m.put("이름", nvl2Rs.getString("이름"));
		m.put("일분기", nvl2Rs.getString("일분기"));
		nvl2List.add(m);
	}
	
	//nullif함수 사용하는 쿼리
	String nullifSql = "select 이름, nullif(사분기, 100) 사분기 from 실적";
	PreparedStatement nullifStmt = conn.prepareStatement(nullifSql);
	
	//쿼리 실행 후 결과값 저장
	ResultSet nullifRs = nullifStmt.executeQuery();
	ArrayList<HashMap<String, Object>> nullifList = new ArrayList<>();
	while(nullifRs.next()){
		HashMap<String, Object> m = new HashMap<>();
		m.put("이름", nullifRs.getString("이름"));
		m.put("사분기", nullifRs.getString("사분기"));
		nullifList.add(m);
	}
	
	//coalesce함수 사용하는 쿼리
	String coalesceSql = "select 이름, coalesce(일분기, 이분기, 삼분기, 사분기) 첫실적 from 실적";
	PreparedStatement coalesceStmt = conn.prepareStatement(coalesceSql);
	
	//쿼리 실행 후 결과값 저장
	ResultSet coalesceRs = coalesceStmt.executeQuery();
	ArrayList<HashMap<String, Object>> coalesceList = new ArrayList<>();
	while(coalesceRs.next()){
		HashMap<String, Object> m = new HashMap<>();
		m.put("이름", coalesceRs.getString("이름"));
		m.put("첫실적", coalesceRs.getInt("첫실적"));
		coalesceList.add(m);
	}
%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>Null Function</title>
	<style>
		table, td{
			border: 1px solid #333333;
		}
		table+table{
			margin-left: 50px;
		}
		div{
			display: flex;
		}
	</style>
</head>
<body>
	<div>
		<table>
			<tr>
				<td colspan="2">nvl</td>
			</tr>
			<tr>
				<td>이름</td>
				<td>일분기</td>
			</tr>
			<%
				for(HashMap<String, Object> m : nvlList){
			%>
					<tr>
						<td><%=(String)m.get("이름") %></td>
						<td><%=(Integer)m.get("일분기") %></td>
					</tr>
			<%
				}
			%>
		</table>
		<table>
			<tr>
				<td colspan="2">nvl2</td>
			</tr>
			<tr>
				<td>이름</td>
				<td>일분기</td>
			</tr>
			<%
				for(HashMap<String, Object> m : nvl2List){
			%>
					<tr>
						<td><%=(String)m.get("이름") %></td>
						<td><%=(String)m.get("일분기") %></td>
					</tr>
			<%
				}
			%>
		</table>
		<table>
			<tr>
				<td colspan="2">nullif</td>
			</tr>
			<tr>
				<td>이름</td>
				<td>사분기</td>
			</tr>
			<%
				for(HashMap<String, Object> m : nullifList){
			%>
					<tr>
						<td><%=(String)m.get("이름") %></td>
						<td><%=(String)m.get("사분기") %></td>
					</tr>
			<%
				}
			%>
		</table>
		<table>
			<tr>
				<td colspan="2">coalesce</td>
			</tr>
			<tr>
				<td>이름</td>
				<td>첫실적</td>
			</tr>
			<%
				for(HashMap<String, Object> m : coalesceList){
			%>
					<tr>
						<td><%=(String)m.get("이름") %></td>
						<td><%=(Integer)m.get("첫실적") %></td>
					</tr>
			<%
				}
			%>
		</table>
	</div>
</body>
</html>