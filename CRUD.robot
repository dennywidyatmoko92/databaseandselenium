*** Settings ***
Library    SeleniumLibrary    
Library    DatabaseLibrary    
Library    OperatingSystem   
Library    pymysql
Library    FakerLibrary         
Library    String
Library    XML


Suite Setup    connect db
Test Teardown    Close Browser



*** Variables ***
${DBName}    sql6581408
${DBUser}    sql6581408
${DBPass}    bX7lkInvL2
${DBHost}    sql6.freemysqlhosting.net
${DBPort}    3306

*** Keywords ***

generate
     ${id}    FakerLibrary.Random Int    min=0    max=100    step=1
  ${name}=          FakerLibrary.Name
  ${email}=         FakerLibrary.Email    mail.com
  ${phoneNumber}=   FakerLibrary.Random Number    digits=11   fix_len=${TRUE}
  ${city}=          FakerLibrary.City
  ${address}=       FakerLibrary.Address
  ${postalCode}=    FakerLibrary.Postcode

  &{DATAUSER}=    Create Dictionary    NAME=${name}
  ...   EMAIL=${email}    PHONE=+62${phoneNumber}
  ...   CITY=${city}      ADDRESS=${address}
  ...   POSTCODE=${postalCode}
  ...    ID=${id}
  [Return]    ${DATAUSER}
            
     
 connect db
    Connect To Database    pymysql    ${DBName}    ${DBUser}    ${DBPass}    ${DBHost}    ${DBPort}    dbConfigFile=default.cfg    
  

open browser web
    seleniumlibrary.Open Browser    https://robotframeworkdatabase.000webhostapp.com/    chrome
    
    


*** Test Cases ***
input form lewat browser
    open browser web
    ${user}=    generate
    Set Global Variable    ${user}
    Go To    https://robotframeworkdatabase.000webhostapp.com/add.html
    Wait Until Element Is Visible    name=nama    100
    Input Text    name=nama    ${user.NAME}
    Input Text    name=umur    ${user.ID}
    Input Text    name=email    ${user.EMAIL}
    Choose File    name=gambar    ${CURDIR}//sampleimagekecil.jpg
    Click Element    name=Submit
    Wait Until Page Contains    Data Berhasil ditambahkan.    100
    
check input dari from pada database
    #connect db
    Check If Exists In Database    select id from ${DBName}.users where email='${user.EMAIL}' AND nama='${user.NAME}';

view data yang barusan di input
    #connect db
    ${queryresult}=    query    select * from ${DBName}.users where email='${user.EMAIL}';
    ${queryresult}=    Set Variable    ${queryresult}[0][0]
    Set Global Variable     ${queryresult}
    Log To Console    ${queryresult}

check delete user not available on database
    open browser web
    Go To    https://robotframeworkdatabase.000webhostapp.com/delete.php?id=${queryresult}
    #connect db
    Check If Not Exists In Database    select id from ${DBName}.users where id=${queryresult};

insert data diri dari db langsung
    ${random_return_address_edit}=     Evaluate    random.sample(range(1,10000), 1)    random
    ${random_return_address_edit}=    Set Variable    ${random_return_address_edit}[0]
    Set Global Variable     ${random_return_address_edit}  

    ${DATAUSER}=    generate
    ${output}=    Execute Sql String    insert into ${DBName}.users values('${random_return_address_edit}', '${DATAUSER.NAME}', '${DATAUSER.ID}', '${DATAUSER.EMAIL}', 'url_gambar');
    Log To Console    ${output} 
    Log To Console    ${random_return_address_edit}
  

view data dari insert an db
    @{queryresult}=    query    select * from ${DBName}.users where id=${random_return_address_edit};
    Log To Console    many @{queryresult}   

check record dari db
    Check If Exists In Database    select id from ${DBName}.users where id=${random_return_address_edit};


view data sort by name
     @{queryresult}=    query    select * from ${DBName}.users order by nama asc
    Log To Console    many @{queryresult}   


update data dari db
    ${DATAUSER_EDIT}=    generate
    Set Global Variable    ${DATAUSER_EDIT}
    Log To Console    UPDATE NAMA MENJADI "${DATAUSER_EDIT.NAME}"    
    Log To Console    UPDATE ALAMAT MENJADI "${DATAUSER_EDIT.EMAIL}"    
    ${output}=    Execute Sql String    update ${DBName}.users set nama="${DATAUSER_EDIT.NAME}",email="${DATAUSER_EDIT.EMAIL}" where id=${random_return_address_edit};
    Log To Console    ${output}    
    Should Be Equal As Strings    ${output}    ${None} 

Check apakah update sudah Berhasil
    Check If Exists In Database    select id from ${DBName}.users where email='${DATAUSER_EDIT.EMAIL}' AND nama='${DATAUSER_EDIT.NAME}';
    ${query_simpan}=    query    select * from ${DBName}.users where email='${DATAUSER_EDIT.EMAIL}' AND nama='${DATAUSER_EDIT.NAME}';
   ${query_simpan}=    Set Variable     ${query_simpan}[0][0]
    Set Global Variable      ${query_simpan}
    Log To Console    id username ${query_simpan}
  #INSERT INTO `users` (`id`, `nama`, `umur`, `email`, `gambar`) VALUES ('12', 'denny widyatmoko', '10', 'dennywidyatmoko@gmail.com', 'denny');

lakukan edit dari form 
    ${DATAUSER_EDIT_FORM}=    generate
    Set Global Variable    ${DATAUSER_EDIT_FORM}
    open browser web
    Go To    https://robotframeworkdatabase.000webhostapp.com/edit.php?id=${query_simpan}
    Wait Until Element Is Visible    name=nama    100
    Clear Element Text    name=nama 
    Clear Element Text    name=umur
    Clear Element Text    name=email
    Input Text    name=nama    ${DATAUSER_EDIT_FORM.NAME}
    Input Text    name=umur    ${DATAUSER_EDIT_FORM.ID}
    Input Text    name=email    ${DATAUSER_EDIT_FORM.EMAIL}
    Click Element    name=update
    Wait Until Element Is Not Visible     name=nama    100
    Log To Console    ${DATAUSER_EDIT_FORM.NAME}    
    Log To Console    ${DATAUSER_EDIT_FORM.ID}  
    Log To Console    ${DATAUSER_EDIT_FORM.EMAIL}  

Check apakah update sudah Berhasil di edit dari form
    Check If Exists In Database    select id from ${DBName}.users where email='${DATAUSER_EDIT_FORM.EMAIL}' AND nama='${DATAUSER_EDIT_FORM.NAME}';        
#delete semua data
    #${output}=    Execute Sql String    delete from sql12574664.users where nama LIKE '%e%'; 
     # Log To Console    ${output}    
    #Should Be Equal As Strings    ${output}    ${None} 

verify halaman sesuai nama pada db muncul
    ${query_simpan}=    query    select * from ${DBName}.users where nama='${DATAUSER_EDIT_FORM.NAME}';
    ${id_user}=    Set Variable    ${query_simpan}[0][0]
    ${nama_user}=    Set Variable    ${query_simpan}[0][1]
    ${usia_user}=    Set Variable    ${query_simpan}[0][2]
    ${email_user}=    Set Variable    ${query_simpan}[0][3]
    ${usia_user}=     Convert To String    ${usia_user}
    Log To Console     ${id_user}
    Log To Console    ${nama_user}
    Log To Console    ${usia_user}
    Log To Console    ${email_user}
    open browser web
    Go To    https://robotframeworkdatabase.000webhostapp.com/edit.php?id=${id_user}
    Wait Until Element Is Visible    name=nama    100 
    ${form_get_nama}=    Get Value    name=nama 
    ${form_get_email}=    Get Value    name=email
    ${form_get_usia}=    Get Value    name=umur 
    Should Be Equal    ${nama_user}    ${form_get_nama}
    Should Be Equal     ${form_get_email}    ${email_user}
    Should Be Equal    ${form_get_usia}    ${usia_user}