
// Example 1: squid:S2077
// Executing SQL queries is security-sensitive. It has led in the past to the following vulnerabilities

Statement st = null;
ResultSet rs = null;
int i = 0;
String sql = "select localizacion from AR_Archivo_Expedientes where expediente = '" + expediente + "'";

try {
    st = con.createStatement();
    rs = st.executeQuery(sql);
    //...
}

