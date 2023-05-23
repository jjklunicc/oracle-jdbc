<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
	//요청값 저장
	int existCurrPage = 1;
	if(request.getParameter("existCurrPage") != null
	&& !request.getParameter("existCurrPage").equals("")){
		existCurrPage = Integer.parseInt(request.getParameter("existCurrPage"));
	}
	int notExistCurrPage = 1;
	if(request.getParameter("notExistCurrPage") != null
	&& !request.getParameter("notExistCurrPage").equals("")){
		notExistCurrPage = Integer.parseInt(request.getParameter("notExistCurrPage"));
	}
	
	//디버깅
	System.out.println("exist_not_exist existCurrPage : " + existCurrPage);
	System.out.println("exist_not_exist notExistCurrPage : " + notExistCurrPage);
	
	//db연결을 위한 변수설정
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dburl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbuser = "hr";
	String dbpw = "1234";
	
	//db연결
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	//exist개수를 불러오기 위한 쿼리
	String existCntSql = "select count(*) cnt from employees e where exists (select e.employee_id, e.first_name from departments d where d.department_id = e.department_id)";
	PreparedStatement existCntStmt = conn.prepareStatement(existCntSql);
	ResultSet existCntRs = existCntStmt.executeQuery();
	
	//not exist개수를 불러오기 위한 쿼리
	String notExistCntSql = "select count(*) cnt from employees e where not exists (select e.employee_id, e.first_name from departments d where d.department_id = e.department_id)";
	PreparedStatement notExistCntStmt = conn.prepareStatement(notExistCntSql);
	ResultSet notExistCntRs = notExistCntStmt.executeQuery();
	
	//exist 전체 개수를 저장
	int existTotalCnt = 0;
	if(existCntRs.next()){
		existTotalCnt = existCntRs.getInt("cnt");	
	}
	//not exist 전체 개수를 저장
	int notExistTotalCnt = 0;
	if(notExistCntRs.next()){
		notExistTotalCnt = notExistCntRs.getInt("cnt");	
	}
	
	//디버깅
	System.out.println("exist_not_exist existTotalCnt : " + existTotalCnt);
	System.out.println("exist_not_exist notExistTotalCnt : " + notExistTotalCnt);

	//공통으로 사용할 페이징 변수
	int rowPerPage = 10;
	int pagePerPage = 5;
	
	//exist 마지막 페이지 구하기
	int existLastPage = existTotalCnt / rowPerPage;
	if(existTotalCnt % rowPerPage != 0){
		existLastPage++;
	}
	
	//not exist 마지막 페이지 구하기
	int notExistLastPage = notExistTotalCnt / rowPerPage;
	if(notExistTotalCnt % rowPerPage != 0){
		notExistLastPage++;
	}
	
	//디버깅
	System.out.println("exist_not_exist existLastPage : " + existLastPage);
	System.out.println("exist_not_exist noExistLastPage : " + notExistLastPage);
	
	//exist 페이지네이션 시작-끝
	int existStartPage = (existCurrPage - 1) / pagePerPage * pagePerPage + 1;
	int existEndPage = existStartPage + pagePerPage - 1;
	if(existEndPage > existLastPage){
		existEndPage = existLastPage;
	}
	
	//디버깅
	System.out.println("exist_not_exist existStartPage : " + existStartPage);
	System.out.println("exist_not_exist existEndPage : " + existEndPage);
	
	//not exist 페이지네이션 시작-끝
	int notExistStartPage = (notExistCurrPage - 1) / pagePerPage * pagePerPage + 1;
	int notExistEndPage = notExistStartPage + pagePerPage - 1;
	if(notExistEndPage > notExistLastPage){
		notExistEndPage = notExistLastPage;
	}
	
	//디버깅
	System.out.println("exist_not_exist notExistStartPage : " + notExistStartPage);
	System.out.println("exist_not_exist notExistEndPage : " + notExistEndPage);

	//exist 페이지 시작행-끝행
	int existStartRow = (existCurrPage - 1) * rowPerPage + 1;
	int existEndRow = existStartRow + rowPerPage - 1;
	if(existEndRow > existTotalCnt){
		existEndRow = existTotalCnt;
	}
	
	//디버깅
	System.out.println("exist_not_exist existStartRow : " + existStartRow);
	System.out.println("exist_not_exist existEndRow : " + existEndRow);
	
	//not exist 페이지 시작행-끝행
	int notExistStartRow = (notExistCurrPage - 1) * rowPerPage + 1;
	int notExistEndRow = notExistStartRow + rowPerPage - 1;
	if(notExistEndRow > notExistTotalCnt){
		notExistEndRow = notExistTotalCnt;
	}
	
	//디버깅
	System.out.println("exist_not_exist notExistStartRow : " + notExistStartRow);
	System.out.println("exist_not_exist notExistEndRow : " + notExistEndRow);
	
	//exist 결과쿼리
	String existSql = "select 사원ID, 이름 from (select e.employee_id 사원ID, e.first_name 이름, rownum rnum from employees e where exists (select e.employee_id, e.first_name from departments d where d.department_id = e.department_id)) where rnum between ? and ?";
	PreparedStatement existStmt = conn.prepareStatement(existSql);
	
	// ? 값 세팅
	existStmt.setInt(1, existStartRow);
	existStmt.setInt(2, existEndRow);
	
	//실행 후 결과 저장
	ResultSet existRs = existStmt.executeQuery();
	ArrayList<HashMap<String, Object>> existList = new ArrayList<>();
	while(existRs.next()){
		HashMap<String, Object> m = new HashMap<>();
		m.put("이름", existRs.getString("이름"));
		m.put("사원ID", existRs.getInt("사원ID"));
		existList.add(m);
	}
	
	//not exist 결과쿼리
	String notExistSql = "select 사원ID, 이름 from (select e.employee_id 사원ID, e.first_name 이름, rownum rnum from employees e where not exists (select e.employee_id, e.first_name from departments d where d.department_id = e.department_id)) where rnum between ? and ?";
	PreparedStatement notExistStmt = conn.prepareStatement(notExistSql);
	
	// ? 값 세팅
	notExistStmt.setInt(1, notExistStartRow);
	notExistStmt.setInt(2, notExistEndRow);
	
	//실행 후 결과 저장
	ResultSet notExistRs = notExistStmt.executeQuery();
	ArrayList<HashMap<String, Object>> notExistList = new ArrayList<>();
	while(notExistRs.next()){
		HashMap<String, Object> m = new HashMap<>();
		m.put("이름", notExistRs.getString("이름"));
		m.put("사원ID", notExistRs.getInt("사원ID"));
		notExistList.add(m);
	}
%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>Exists Not Exists</title>
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
			<td>사원ID</td>
			<td>이름</td>
		</tr>
		<%
			for(HashMap<String, Object> m : existList){
		%>
				<tr>
					<td><%=(Integer)m.get("사원ID") %></td>
					<td><%=(String)m.get("이름") %></td>
				</tr>
		<%
			}
		%>
	</table>
	<%
		if(existStartPage != 1){
	%>
			<a href="exists_not_exists.jsp?existCurrPage=<%=existCurrPage - pagePerPage %>&notExistCurrPage=<%=notExistCurrPage %>">이전</a>
	<%
		}
		for(int i = existStartPage; i <= existEndPage; i++){
			String selected = i == existCurrPage ? "selected" : "";
	%>
			<a href="exists_not_exists.jsp?existCurrPage=<%=i %>&notExistCurrPage=<%=notExistCurrPage %>" class=<%=selected %>><%=i %></a>
	<%
		}
		if(existEndPage != existLastPage){
	%>
			<a href="exists_not_exists.jsp?existCurrPage=<%=existEndPage + 1%>&notExistCurrPage=<%=notExistCurrPage %>">다음</a>
	<%
		}
	%>
	<hr>
	<table>
		<tr>
			<td>사원ID</td>
			<td>이름</td>
		</tr>
		<%
			for(HashMap<String, Object> m : notExistList){
		%>
				<tr>
					<td><%=(Integer)m.get("사원ID") %></td>
					<td><%=(String)m.get("이름") %></td>
				</tr>
		<%
			}
		%>
	</table>
	<%
		if(notExistStartPage != 1){
	%>
			<a href="exists_not_exists.jsp?existCurrPage=<%=existCurrPage %>&notExistCurrPage=<%=notExistCurrPage - pagePerPage %>">이전</a>
	<%
		}
		for(int i = notExistStartPage; i <= notExistEndPage; i++){
			String selected = i == notExistCurrPage ? "selected" : "";
	%>
			<a href="exists_not_exists.jsp?existCurrPage=<%=existCurrPage %>&notExistCurrPage=<%=i %>" class=<%=selected %>><%=i %></a>
	<%
		}
		if(notExistEndPage != notExistLastPage){
	%>
			<a href="exists_not_exists.jsp?existCurrPage=<%=existCurrPage%>&notExistCurrPage=<%=notExistEndPage + 1 %>">다음</a>
	<%
		}
	%>
</body>
</html>