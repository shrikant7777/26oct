CREATE OR REPLACE FUNCTION AP_X_API_FETCH_Staff_Details(  VAR_PI_CHANGE_CODE         IN VARCHAR2,
                                                          VAR_PI_PAN_NUM             IN VARCHAR2,
                                                          VAR_PI_ACC_NUM             IN VARCHAR2,
                                                          VAR_PI_EMP_ID              IN VARCHAR2,
                                                          VAR_PI_EFFDATE             IN VARCHAR2,
                                                          VAR_PI_DATE_JOINING        IN VARCHAR2,
                                                          VAR_PI_DATE_TERMINATION    IN VARCHAR2,
                                                          VAR_PI_SCALE               IN VARCHAR2,
                                                          VAR_PI_HR_STATUS           IN VARCHAR2,
                                                          VAR_PI_MAKER               IN VARCHAR2,
                                                          VAR_PI_CHECKER             IN VARCHAR2,
                                                          VAR_PI_DAT_LAST_MNT        IN VARCHAR2,
                                                          VAR_PO_CUSTID              OUT NUMBER
                                                         )

RETURN NUMBER AS


var_l_cod_prod               NUMBER:=0;
var_l_cod_cust               VARCHAR2(100);
var_l_cod_pan                VARCHAR2(100);
var_l_acct_type              VARCHAR2(10);
var_l_cur_date               VARCHAR2(10);
var_l_flg_staff              VARCHAR2(10);
var_l_temp1                  NUMBER:=0;

BEGIN
var_l_temp1:=Length(ch => VAR_PI_PAN_NUM);
select TO_DATE(dat_process,'DD-MM-YYYY') into  var_l_cur_date from ba_bank_mast;


IF (VAR_PI_CHANGE_CODE='HIR' OR VAR_PI_CHANGE_CODE='hir') THEN
   BEGIN
   If(VAR_PI_EMP_ID='NULL' AND VAR_PI_EFFDATE='NULL' AND VAR_PI_ACC_NUM='NULL' AND VAR_PI_PAN_NUM='NULL' AND VAR_PI_DATE_JOINING='NULL' AND VAR_PI_SCALE='NULL' AND VAR_PI_HR_STATUS='NULL'   )THEN
     BEGIN
     RETURN 3245;
     END;
            ELSE 
              BEGIN
              SELECT cod_cust,cod_prod INTO var_l_cod_cust,var_l_cod_prod FROM ch_acct_mast WHERE TRIM(cod_acct_no)=TRIM(VAR_PI_ACC_NUM) AND FLG_MNT_STATUS='A';
              SELECT cod_pan_card INTO var_l_cod_pan from CI_KYC_DETAILS WHERE TRIM(cod_cust_id)=TRIM(var_l_cod_cust) AND FLG_MNT_STATUS='A';
              Select FLG_RD INTO var_l_acct_type FROM CH_PROD_MAST WHERE COD_PROD=var_l_cod_prod;
              Select flg_staff INTO var_l_flg_staff from ci_custmast  where cod_cust_id=var_l_cod_cust AND FLG_MNT_STATUS='A';
              If(var_l_temp1<11 and var_l_cod_pan=VAR_PI_PAN_NUM and var_l_acct_type='N')THEN
                         BEGIN
                         IF(to_date(VAR_PI_EFFDATE,'DD-MM-YY')<to_date(var_l_cur_date,'DD-MM-YY') AND to_date(VAR_PI_DATE_JOINING,'DD-MM-YY') <=to_date(var_l_cur_date,'DD-MM-YY') ) THEN
                         BEGIN
                         INSERT INTO CI_CUST_HRMS(cod_employee_id,dat_effective,cod_acct_no,cod_pan_card,DAT_JOINING,DAT_TERMINATION,Present_Scale,Hr_status,Cust_Id,DAT_LAST_UPDATE,
                         FLG_MNT_STATUS,COD_MNT_ACTION,COD_LAST_MNT_MAKERID,COD_LAST_MNT_CHKRID,DAT_LAST_MNT,CTR_UPDAT_SRLNO)
                         VALUES(VAR_PI_EMP_ID,to_date(VAR_PI_EFFDATE,'DD-MM-YY'),VAR_PI_ACC_NUM,VAR_PI_PAN_NUM,to_date(VAR_PI_DATE_JOINING,'DD-MM-YY') ,to_date(VAR_PI_DATE_TERMINATION,'DD-MM-YY'),VAR_PI_SCALE,VAR_PI_HR_STATUS ,var_l_cod_cust,
                         '','A','',VAR_PI_MAKER,VAR_PI_CHECKER,to_date(VAR_PI_DAT_LAST_MNT,'DD-MM-YY'),'') ;  
                         commit;
                         VAR_PO_CUSTID:=var_l_cod_cust;
                         if(var_l_flg_staff='N')THEN
                               BEGIN
                               UPDATE ci_custmast 
                               SET flg_staff ='Y'
                               WHERE  cod_cust_id=var_l_cod_cust;
                               commit;
                               END;
                               END IF;  
                              return 0;
                         END;
                         else return 3247;
                         end if;
                         end;
              else return 3248;
              END IF;
              END;
   END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
      RETURN 1;
      WHEN OTHERS THEN
            ora_raiserror(SQLCODE,'Error while loading Data',
                          465);
            RETURN 1;     
   END;  
   
   
   
ELSE IF (VAR_PI_CHANGE_CODE='PAN' or VAR_PI_CHANGE_CODE='pan') THEN
     BEGIN
       select cod_cust_id into var_l_cod_cust from CI_KYC_DETAILS where cod_pan_card= VAR_PI_PAN_NUM AND FLG_MNT_STATUS='A';
       If(VAR_PI_EMP_ID <> 'NULL' and VAR_PI_EFFDATE <> 'NULL'  and VAR_PI_PAN_NUM <> 'NULL' )THEN
       BEGIN
            IF( to_date(VAR_PI_EFFDATE,'DD-MM-YY')<to_date(var_l_cur_date,'DD-MM-YY') )THEN
               BEGIN
               INSERT INTO CI_CUST_HRMS(cod_employee_id,dat_effective,cod_acct_no,cod_pan_card,DAT_JOINING,DAT_TERMINATION,Present_Scale,Hr_status,Cust_Id,DAT_LAST_UPDATE,
               FLG_MNT_STATUS,COD_MNT_ACTION,COD_LAST_MNT_MAKERID,COD_LAST_MNT_CHKRID,DAT_LAST_MNT,CTR_UPDAT_SRLNO)
               VALUES(VAR_PI_EMP_ID,to_date(VAR_PI_EFFDATE,'DD-MM-YY'),VAR_PI_ACC_NUM,VAR_PI_PAN_NUM,to_date(VAR_PI_DATE_JOINING,'DD-MM-YY') ,to_date(VAR_PI_DATE_TERMINATION,'DD-MM-YY'),VAR_PI_SCALE,VAR_PI_HR_STATUS ,var_l_cod_cust,
               '','A','',VAR_PI_MAKER,VAR_PI_CHECKER,to_date(VAR_PI_DAT_LAST_MNT,'DD-MM-YY'),'') ;  
               commit;
               VAR_PO_CUSTID:=var_l_cod_cust;
               return 0;               
               END;
               ELSE RETURN 3247;
               END IF;
        END;
        ELSE return 3245;
        END IF;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
         RETURN 1;
    WHEN OTHERS THEN
           ora_raiserror(SQLCODE,'Error while loading Data',
                          465);
            RETURN 1;      
    END; 
   
   
   
   
ELSE IF (VAR_PI_CHANGE_CODE='AC' or VAR_PI_CHANGE_CODE='ac')  THEN
    BEGIN
       SELECT cod_prod,cod_cust INTO var_l_cod_prod,var_l_cod_cust FROM ch_acct_mast WHERE TRIM(cod_acct_no)=TRIM(VAR_PI_ACC_NUM) AND FLG_MNT_STATUS='A';  
       Select FLG_RD INTO var_l_acct_type FROM CH_PROD_MAST WHERE COD_PROD=var_l_cod_prod;
       If(VAR_PI_EMP_ID='NULL' AND VAR_PI_EFFDATE='NULL'  AND VAR_PI_ACC_NUM='NULL' AND var_l_acct_type='N'  )THEN
          BEGIN
          IF( to_date(VAR_PI_EFFDATE,'DD-MM-YY')<to_date(var_l_cur_date,'DD-MM-YY') )THEN
              BEGIN
              INSERT INTO CI_CUST_HRMS(cod_employee_id,dat_effective,cod_acct_no,cod_pan_card,DAT_JOINING,DAT_TERMINATION,Present_Scale,Hr_status,Cust_Id,DAT_LAST_UPDATE,
              FLG_MNT_STATUS,COD_MNT_ACTION,COD_LAST_MNT_MAKERID,COD_LAST_MNT_CHKRID,DAT_LAST_MNT,CTR_UPDAT_SRLNO)
              VALUES(VAR_PI_EMP_ID,to_date(VAR_PI_EFFDATE,'DD-MM-YY'),VAR_PI_ACC_NUM,VAR_PI_PAN_NUM,to_date(VAR_PI_DATE_JOINING,'DD-MM-YY') ,to_date(VAR_PI_DATE_TERMINATION,'DD-MM-YY'),VAR_PI_SCALE,VAR_PI_HR_STATUS ,var_l_cod_cust,
              '','A','',VAR_PI_MAKER,VAR_PI_CHECKER,to_date(VAR_PI_DAT_LAST_MNT,'DD-MM-YY'),'') ; 
              commit;
              VAR_PO_CUSTID:=var_l_cod_cust;
                         return 0;              
              END;
              ELSE RETURN 3247;
              END IF;
        END;
        ELSE return 3245;
   END IF;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN 1;
   WHEN OTHERS THEN
           ora_raiserror(SQLCODE,'Error while loading Data',
                          465);
      RETURN 1;        
   END; 
   
   
   
   
   
ELSE IF (VAR_PI_CHANGE_CODE='TER' or VAR_PI_CHANGE_CODE='ter')  THEN
   BEGIN
       SELECT COD_CUST_ID INTO var_l_cod_cust  FROM ci_custmast WHERE cod_employee_id=VAR_PI_EMP_ID AND FLG_MNT_STATUS='A';
       If(VAR_PI_EMP_ID!='NULL' AND VAR_PI_EFFDATE!='NULL' AND   VAR_PI_DATE_TERMINATION!='NULL'  AND VAR_PI_HR_STATUS!='NULL'   )THEN
         BEGIN
             IF(to_date(VAR_PI_EFFDATE,'DD-MM-YY')<to_date(var_l_cur_date,'DD-MM-YY') AND to_date(VAR_PI_DATE_TERMINATION,'DD-MM-YY')< to_date(var_l_cur_date,'DD-MM-YY'))THEN
              BEGIN
              INSERT INTO CI_CUST_HRMS(cod_employee_id,dat_effective,cod_acct_no,cod_pan_card,DAT_JOINING,DAT_TERMINATION,Present_Scale,Hr_status,Cust_Id,DAT_LAST_UPDATE,
              FLG_MNT_STATUS,COD_MNT_ACTION,COD_LAST_MNT_MAKERID,COD_LAST_MNT_CHKRID,DAT_LAST_MNT,CTR_UPDAT_SRLNO)
              VALUES(VAR_PI_EMP_ID,to_date(VAR_PI_EFFDATE,'DD-MM-YY'),VAR_PI_ACC_NUM,VAR_PI_PAN_NUM,to_date(VAR_PI_DATE_JOINING,'DD-MM-YY') ,to_date(VAR_PI_DATE_TERMINATION,'DD-MM-YY'),VAR_PI_SCALE,VAR_PI_HR_STATUS ,var_l_cod_cust,
              '','A','',VAR_PI_MAKER,VAR_PI_CHECKER,to_date(VAR_PI_DAT_LAST_MNT,'DD-MM-YY'),'') ;  
              commit;
              VAR_PO_CUSTID:=var_l_cod_cust;
              return 0;                  
              END;
              ELSE RETURN 3247;
              END IF;
         END;
        ELSE return 3245;
    END IF;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
            RETURN 1;
    WHEN OTHERS THEN
            ora_raiserror(SQLCODE,'Error while loading Data',
                          465);
            RETURN 1;        
   END; 
   
   
   
   
ELSE IF (VAR_PI_CHANGE_CODE='SCL' or VAR_PI_CHANGE_CODE='scl') THEN 
    BEGIN
      SELECT COD_CUST_ID INTO var_l_cod_cust  FROM ci_custmast WHERE cod_employee_id=VAR_PI_EMP_ID AND FLG_MNT_STATUS='A';
      If(VAR_PI_EMP_ID!='NULL' AND VAR_PI_EFFDATE!='NULL' AND   VAR_PI_DATE_TERMINATION!='NULL'  AND VAR_PI_SCALE!='NULL'   )THEN
        BEGIN
          IF(to_date(VAR_PI_EFFDATE,'DD-MM-YY')<to_date(var_l_cur_date,'DD-MM-YY'))THEN
              BEGIN                
              INSERT INTO CI_CUST_HRMS(cod_employee_id,dat_effective,cod_acct_no,cod_pan_card,DAT_JOINING,DAT_TERMINATION,Present_Scale,Hr_status,Cust_Id,DAT_LAST_UPDATE,
              FLG_MNT_STATUS,COD_MNT_ACTION,COD_LAST_MNT_MAKERID,COD_LAST_MNT_CHKRID,DAT_LAST_MNT,CTR_UPDAT_SRLNO)
              VALUES(VAR_PI_EMP_ID,to_date(VAR_PI_EFFDATE,'DD-MM-YY'),VAR_PI_ACC_NUM,VAR_PI_PAN_NUM,to_date(VAR_PI_DATE_JOINING,'DD-MM-YY') ,to_date(VAR_PI_DATE_TERMINATION,'DD-MM-YY'),VAR_PI_SCALE,VAR_PI_HR_STATUS ,var_l_cod_cust,
              '','A','',VAR_PI_MAKER,VAR_PI_CHECKER,to_date(VAR_PI_DAT_LAST_MNT,'DD-MM-YY'),'') ;
              commit;
              VAR_PO_CUSTID:=var_l_cod_cust;
              return 0;
              END;
              ELSE RETURN 3247;
              END IF;        
            END;
        ELSE return 3245;
     END IF;
     EXCEPTION
     WHEN NO_DATA_FOUND THEN
        RETURN 1;
     WHEN OTHERS THEN
           ora_raiserror(SQLCODE,'Error while loading Data',
                          465);
            RETURN 1;   
   END; 
ELSE 
  
   BEGIN
     RETURN 3246;
   END;     
END IF;
END IF;
END IF;
END IF;
END IF;
END;
