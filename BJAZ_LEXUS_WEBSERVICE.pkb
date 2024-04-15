CREATE OR REPLACE PACKAGE BODY CUSTOMER.BJAZ_LEXUS_WEBSERVICE
AS
-------------------------------------------------------------------------------
/*
======================================
=   AUTHOR  :   Abhishek
=   DATED   :   26-JULY-2023
=   PURPOSE :   FOR LEXUS WEB SERVICE
===============================================================================
VERSION        DATE            WHO          PURPOSE
===============================================================================
1.00         26-JULY-2023   Abhishek   INITIAL VERSION
===============================================================================
*/
-------------------------------------------------------------------------------


PROCEDURE upload_policy (
      p_LEXUSpono       IN   bjaz_LEXUS_ws_data.transactionid%TYPE
            DEFAULT NULL,
      p_process_always   IN   VARCHAR2 DEFAULT 'N',
      p_chk_errors_yn    IN   VARCHAR2 DEFAULT 'N',
      p_flag             IN   VARCHAR2 DEFAULT 'N'
   )
   IS
      v_short_limit               NUMBER;
      v_count                     NUMBER (5);
      v_ques_count                NUMBER (5);
      v_unique_ref_no             VARCHAR2 (100);
      p_error_code                NUMBER (7)                             := 0;
      p_fuel_name                 VARCHAR2 (100);
      v_new_eff_date              DATE;
      v_rate                      NUMBER;
      v_pol_count                 NUMBER;
      p_error                     weo_tyge_error_message_list;
      v_error                     weo_tyge_error_message;
      ppremiumpayerid             NUMBER;
      geog_extn                   VARCHAR2 (30);
      ppolicyref                  VARCHAR2 (30);
      ppolicyissuedate            VARCHAR2 (30);
      ppart_id                    VARCHAR2 (30);
      paymentmode                 VARCHAR2 (30);
      v_bankname                  VARCHAR2 (100);
      locationid                  VARCHAR2 (30);
      p_instrument_type           VARCHAR2 (30);
      prodcode                    VARCHAR2 (30);
      partner_type                VARCHAR2 (30);
      insured_name                VARCHAR2 (200);
      error_comments              VARCHAR2 (1500);
      address1                    VARCHAR2 (100);
      address2                    VARCHAR2 (100);
      v_cityname                  VARCHAR2 (100);
      v_statename                 VARCHAR2 (100);
      v_veh_fuel_from_mst         VARCHAR2 (30);
      fuel_type                   VARCHAR2 (10);
      loccode                     VARCHAR2 (30);
      v_instr_type                VARCHAR2 (10);
      v_partner_addr              VARCHAR2 (2)                        := '--';
      v_cnt                       NUMBER (5);
      financed_type               NUMBER (5);
      prvinscompany               VARCHAR2 (50);
      vehicletypecode             bjaz_vehicle_model_master.vehicle_type_code%TYPE;
      vehiclemakecode             NUMBER;
      vehiclemodelcode            bjaz_vehicle_model_master.vehicle_make_code%TYPE;
      vehiclesubtypecode          bjaz_vehicle_model_master.vehicle_subtype_code%TYPE;
      miscvehtypecode             bjaz_vehicle_model_master.misc_veh_type_code%TYPE;
      pidvvalue                   NUMBER;
      p_error_mesg                VARCHAR2 (4000);
      v_vehicle_type              VARCHAR2 (1)                         := 'P';
      v_chequeno                  VARCHAR2 (30);
      v_total_chequeamount        VARCHAR2 (100);
      v_receipt_no                bjaz_nissan_ws_data.bjaz_receipt%TYPE;
      bjaz_ski_part               bjaz_ski_partner;
      reciept_mst                 bjaz_ski_reciept_mst;
      inst_obj                    bjaz_ski_instument;
      inst_list                   bjaz_ski_instument_list;
      prod_obj                    bjaz_ski_product;
      prod_list                   bjaz_ski_product_list;
      p_weo_mot_policy_in         weo_mot_plan_details;
      accessories_obj             weo_mot_accessories;
      accessories_list            weo_mot_accessories_list;
      paddoncover_obj             weo_mot_gen_param;
      paddoncover_list            weo_mot_gen_param_list;
      mot_extra_cover             weo_sig_mot_extra_covers;
      phiddenvar                  weo_mot_vechilepage_hidden_var;
      p_quest_obj                 weo_bjaz_mot_questionary;
      p_quest_list                weo_bjaz_mot_quest_list;
      premium_details_out         weo_mot_premium_details;
      premium_summery_obj         weo_mot_premium_summary;
      premium_summery_list        weo_mot_premium_summary_list;
      p_rcpt_obj                  weo_tyac_pay_row;
      p_rcpt_list                 weo_tyac_pay_list;
      p_cust_details              weo_b2c_cust_details;
      potherdetails               weo_sig_other_details;
      p_receipt_dtls              weo_rec_strings10;
      v_rcpt_rslt                 NUMBER;
      p_rcpt_bal                  NUMBER;
      v_driveassure_prem          NUMBER;
      v_nildep_prem               NUMBER;
      v_premium                   NUMBER;
      v_diff_prem                 NUMBER;
      v_conf_percent              NUMBER;
      v_prv_comp_code             NUMBER;
      v_scrutiny_no               NUMBER;
      p_scr_dtls_list             weo_rec_strings40_list;
      v_tieup_name                VARCHAR2 (10);
      scrutiny_count              NUMBER;
      v_result                    NUMBER;
      v_contract_id               ocp_policy_bases.contract_id%TYPE;
      v_receipt_batch_id          bjaz_scr_rcpt_tag.receipt_batch_id%TYPE;
      v_transfer_batch            bjaz_scr_rcpt_tag.transfer_batch%TYPE;
      v_cnt_covernote             NUMBER                                 := 0;
      v_bjaz_premium              bjaz_nissan_ws_data.bjaz_premium%TYPE;
      v_cheq_amt                  bjaz_dfs_data_extn.paymentamount%TYPE;
      v_rcpt_remarks              VARCHAR2 (1000);
      v_err_msg                   VARCHAR2 (1000);
      v_vehicle_make              bjaz_vehicle_make_master.vehicle_make%TYPE;
      v_vehicle_model             bjaz_vehicle_model_master.vehicle_model%TYPE;
      v_vehicle_subtype           bjaz_vehicle_model_master.vehicle_subtype%TYPE;
      v_proceed_flag              VARCHAR2 (1);
      v_reg_no                    VARCHAR2 (50);
      v_block_msg                 VARCHAR2 (100);
      v_mainimdcode               bjaz_dfs_dealer_dtls.mainimdcode%TYPE;
      v_dealerlevelimd            bjaz_dfs_dealer_dtls.dealerlevelimd%TYPE;
      v_dealerlevelsubimd         bjaz_dfs_dealer_dtls.dealerlevelsubimd%TYPE;
      v_bjazloctioncode           bjaz_dfs_dealer_dtls.bjazloctioncode%TYPE;
      p_veh_make_code             bjaz_dfs_variant_dtls.vehiclemakecode%TYPE;
      v_bank_name                 VARCHAR2 (100);
      v_payment_date              DATE;
      v_compare_prem              NUMBER;
      v_carringcap                NUMBER;
      v_stax_dtls                 bjaz_service_tax_master_obj;
      v_stax_dtls_basic_tp        bjaz_service_tax_master_obj;
      v_stax_dtls_other_tp        bjaz_service_tax_master_obj;
      v_bg_count                  NUMBER;
      v_bg_no                     bjaz_bg_master.bg_no%TYPE;
      v_pin_app_cnt               NUMBER;
      v_upload_flg                NUMBER;
      v_stage                     VARCHAR2 (500);
      v_llprem                    NUMBER;
      v_paprem                    NUMBER;
      v_tzone_private             VARCHAR2 (10);
      v_tp_effective_date         DATE;
      v_tpcurrent_policy_tenure   NUMBER;
      v_policy_ref                bjaz_LEXUS_ws_data.bjazpolicyno%TYPE;
      v_pannumber                 VARCHAR2 (15);
      st_od_validation     VARCHAR2 (500)  := NULL;
      v_branchname_withPolno    VARCHAR2 (500);
      ncb_prev_validation   VARCHAR2(4000);
      l_cust_float                bjaz_pk0_general.cust_float_rec;
      v_nf_imd_code               VARCHAR2 (500):= NULL;
      v_rcpt_type                  VARCHAR2 (500);
      v_chassis_no   VARCHAR2 (1000) := NULL;--added by abhishek for call 54724175
      H_CUSTOMER_DTLS           WEO_REC_STRINGS10;
      v_diffdays number(20);
      v_Tenure_validation      VARCHAR2 (500);   
   BEGIN
      p_error := weo_tyge_error_message_list ();
      p_scr_dtls_list := weo_rec_strings40_list ();
      p_receipt_dtls :=
         weo_rec_strings10 (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                            NULL, NULL);
      DBMS_OUTPUT.put_line ('Step 1.1 before loop');
      BJAZ_LEXUS_WEBSERVICE.upd_LEXUS_branch_code (p_LEXUSpono);
      DBMS_OUTPUT.put_line ('Step 1.1 update branch code');
      BJAZ_LEXUS_WEBSERVICE.upd_LEXUS_vcode (p_LEXUSpono);
      DBMS_OUTPUT.put_line ('Step 1.1 updated vcode');
      DBMS_OUTPUT.put_line ('Step 1.1>>>before loop ' || gv_LEXUS_polno);

      <<lpol>>
      FOR lpol IN (SELECT A.*
                   FROM   bjaz_LEXUS_ws_data A JOIN bjaz_LEXUS_ws_data_EXTN B
                   ON A.transactionid=B.transactionid
                   WHERE  A.transactionid IS NOT NULL
                          AND A.transactionid = p_LEXUSpono
                          AND A.bjaz_loc_code IS NOT NULL
                          AND A.bjaz_veh_code IS NOT NULL
                          AND B.reconciledchequedate IS NOT NULL
                          AND B.reconciledchequebank IS NOT NULL
                          AND B.reconciledchequebranch IS NOT NULL
                          AND B.reconciledchequeamount IS NOT NULL
                          AND A.last_uploaddate IS NOT NULL
                          AND NVL (B.grosspremium, 0) > 0
                          AND bjazpolicyno IS NULL
                          AND NVL (A.processed, 'N') = 'N'
                          AND NVL (A.ERROR_CODE, 0) > -1) LOOP



         BEGIN
            gv_LEXUS_polno := lpol.transactionid;
            DBMS_OUTPUT.put_line ('Step 1>>> ' || gv_LEXUS_polno);

            BEGIN
               UPDATE bjaz_LEXUS_ws_data
               SET error_desc = NULL
               WHERE  transactionid = lpol.transactionid;
           COMMIT;
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            gv_LEXUS_basic_od_prem := lpol.basicodp;
            gvx_LEXUS_vehicle_od := NULL;
            gvx_LEXUS_vehicle_od := NVL (lpol.basicodp, 0);
            DBMS_OUTPUT.put_line ('Step 2>>> ' || gv_LEXUS_polno);

            BEGIN
               SELECT TRUNC (effective_date)
               INTO   v_tp_effective_date
               FROM   bjaz_gen_param_master
               WHERE  param_ref = 'DLRTPEFFDT';
            EXCEPTION
               WHEN OTHERS THEN
                  v_tp_effective_date := SYSDATE;
            END;

            <<l_lpolextn>>
            FOR lpolextn IN (SELECT *
                             FROM   bjaz_LEXUS_ws_data_extn
                             WHERE  transactionid = lpol.transactionid) LOOP

BEGIN
DBMS_output.put_line('CKYC FLAG = '||LPOLEXTN.CKYC_FLAG);
  IF NVL(LPOLEXTN.CKYC_FLAG,0)=1
    THEN
DBMS_output.put_line('CKYC FLAG IS ON');
        IF bjaz_utils.get_param_value('LEXUS_CKYC', 0, 0, SYSDATE) = 1 THEN
          DBMS_output.put_line('LEXUS_CKYC');
          H_CUSTOMER_DTLS := WEO_REC_STRINGS10(NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL);

          bjaz_honda_utils.GET_KYC_STATUS(lpolextn.CKYC_DOCUMENT_REFERENCE_NUMBER,
                                          lpolextn.CKYC_NUMBER,
                                          error_comments,
                                          p_error_code,
                                          H_CUSTOMER_DTLS);
          DBMS_OUTPUT.put_line('error_comments>' || error_comments);
          DBMS_OUTPUT.put_line('p_error_code>' || p_error_code);

          IF p_error_code = 0 THEN
            UPDATE bjaz_LEXUS_ws_data
               SET ERROR_CODE = p_error_code, error_desc = error_comments
             WHERE transactionid = lpol.transactionid;
            save_error_code(lpol.transactionid,
                            p_error_code,
                            error_comments);

            COMMIT;
            RETURN;
          END IF;

        END IF;
	ELSE
          error_comments:='CKYC FLAG IS 0';
           UPDATE bjaz_LEXUS_ws_data
               SET error_desc = error_comments
             WHERE transactionid = lpol.transactionid;
              save_error_code(lpol.transactionid,
                            p_error_code,
                            error_comments);

            COMMIT;
            RETURN;
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
        WHEN OTHERS THEN
          NULL;
      END;

             BEGIN--50266577
DBMS_OUTPUT.put_line ('266 bjaz_LEXUS_webservice>>>');
              IF NVL (lpol.basicodp_year2, 0) <> 0 AND NVL (lpol.basicodp_year3, 0) <> 0
               THEN
                 DBMS_OUTPUT.put_line ('268 bjaz_LEXUS_webservice>>>');
                  error_comments :=
                     bjaz_mibl_web_service.is_product_blocked
                                       (TO_DATE (lpol.inspolicyeffectivedate),
                                        lpol.transactionid
                                       );
                  COMMIT;
                    IF error_comments <> 'X'
                     THEN
                       COMMIT;
                     p_error_code := 1;
                     save_error_code (lpol.transactionid, p_error_code,
                                      error_comments);
                      RETURN;
                    END IF;
                END IF;
             EXCEPTION WHEN OTHERS THEN
                NULL;
             END;

               BEGIN
DBMS_OUTPUT.put_line ('295 bjaz_LEXUS_webservice>>>');
                  IF UPPER (TRIM (NVL (lpol.vehicleclass, NULL))) = 'P' THEN
                     IF lpol.inspolicytype = 'N'
                        AND trunc(to_date(lpol.VEHICLEINVOICEDATE, 'MM/DD/YYYY HH24:MI:SS')) >= v_tp_effective_date THEN

                        IF lpol.basicodp_year2 IS NOT NULL
                           AND lpol.basicodp_year2 <> 0 THEN
                            prodcode := '1827';
                        ELSE
                            prodcode := '1825';
                        END IF;                         --'1801';

                     ELSE
                        IF lpolextn.isstandaloneod = 1
                        THEN                                 --sandip 48924434
                           prodcode := '1870';
                        ELSIF nvl(lpolextn.netodpremium,0) =0
                        THEN
                           prodcode := '1805';
                        ELSE
                           prodcode := '1801';
                        END IF;
                     END IF;

                     v_vehicle_type := 'P';
                  ELSIF UPPER (TRIM (NVL (lpol.vehicleclass, NULL))) IN
                                                                   ('C', 'P') THEN
                     v_vehicle_type := 'C';

                     IF lpol.seatingcapacity <= 7 THEN
                        prodcode := '1803';
                     ELSIF lpol.seatingcapacity >= 8 THEN
                        prodcode := '1812';
                     END IF;
                  ELSE
                     COMMIT;
                     p_error_code := 1;
                     error_comments := ' VEHICLE TYPE IS NOT MENTIONED ';
                     save_error_code (lpol.transactionid, p_error_code,
                                      error_comments);
                     RETURN;
                  END IF;

		   IF prodcode = '1801' THEN
                         v_tpcurrent_policy_tenure := 1;
                     ELSE
                     BEGIN
                        SELECT NVL (DECODE (longtermpolicy, 2, 3, 1, 1), 1)
                        INTO   v_tpcurrent_policy_tenure
                        FROM   customer.bjaz_lexus_ws_data_extn /*abhishek*/
                        WHERE  transactionid = lpol.transactionid;
                     EXCEPTION
                        WHEN OTHERS THEN
                           v_tpcurrent_policy_tenure := 1;
                     END;
                  END IF;

		  /*start: abhishek*/        
         IF prodcode = '1825' THEN
                         v_tpcurrent_policy_tenure := 3;                  
                         end if;
          /*end; abhishek*/

		 BEGIN
       customer.bjaz_toyota_web_service.NTU_TENURE_VALIDATION (
                       P_PROD_CODE       => prodcode,
                       P_START_DATE      => TO_CHAR(TRUNC(TO_DATE(lpol.inspolicyeffectivedate, 'MM/DD/YYYY HH24:MI:SS')),'DD-MON-YYYY'),/*ABHISHEK*/
                       P_END_DATE        => TO_CHAR(TRUNC(TO_DATE(lpol.inspolicyexpirydate, 'MM/DD/YYYY HH24:MI:SS')),'DD-MON-YYYY'),/*ABHISHEK*/
                       P_TP_START_DATE   => TO_CHAR(TRUNC(TO_DATE(lpolextn.instpeffectivedate, 'MM/DD/YYYY HH24:MI:SS')),'DD-MON-YYYY'),/*ABHISHEK*/
                       P_TP_END_DATE     => TO_CHAR(TRUNC(TO_DATE(lpolextn.instpexpirydate, 'MM/DD/YYYY HH24:MI:SS')),'DD-MON-YYYY'),/*ABHISHEK*/
                       tpcurrent_policy_tenure => v_tpcurrent_policy_tenure,
                       P_VALIDATE_DATE   => v_Tenure_validation);

    EXCEPTION
     WHEN OTHERS THEN
      DBMS_OUTPUT.put_line('Error :  ' || SQLERRM ||
                         Dbms_Utility.format_error_stack ||
                         Dbms_Utility.format_error_backtrace);
    END;
    DBMS_OUTPUT.put_line('v_Tenure_validation : '||v_Tenure_validation);
    IF v_Tenure_validation='TRUE'  THEN
    NULL;
    ELSE
      p_error_code := 1;
      save_error_code (lpol.transactionid,
      p_error_code,
      'Prodcut code and policy tenure not matching.Please check Policy RID/RED and Tp tenure.>>'||prodcode);
    RETURN;                 
    END IF; 

			Begin            
      v_diffdays:=trunc(to_date(lpol.inspolicyeffectivedate,'MM/DD/YYYY HH24:MI:SS'))-trunc(to_date(lpol.vehicleinvoicedate,'MM/DD/YYYY HH24:MI:SS'));/*ABHISHEK*/
      Dbms_Output.put_line('v_diffdays :'||v_diffdays);
      IF v_diffdays<=180 AND lpol.inspolicytype<>'N' THEN
         COMMIT;
		 p_error_code := 1;
                     error_comments := 'SELECTED AGE CRETIRIA IS NOT APPLICABLE FOR RENEWAL/ROLLOVER  KINDLY ISSUE THE POLICY IN NEW BUSINESS';
                     save_error_code (lpol.transactionid, p_error_code,
                                      error_comments);
                     RETURN;  
      ELSIF v_diffdays>180 AND lpol.inspolicytype='N' THEN
         COMMIT;
		 p_error_code := 1;
                     error_comments := 'SELECTED AGE CRETIRIA IS NOT APPLICABLE FOR NEW BUSINESS KINDLY ISSUE THE POLICY IN RENEWAL';
                     save_error_code (lpol.transactionid, p_error_code,
                                      error_comments);
                     RETURN; 

      END IF;  
      Exception
        When others then
          Dbms_Output.put_line('Error :'||SQLERRM||Dbms_Utility.format_error_stack||Dbms_Utility.format_error_backtrace);
      End;

            IF  NVL (lpol.ncbper, 0) <> 0 THEN
dbms_output.put_line('lpolextn.PREVPOLICYEXPIRYDATE= '||lpolextn.PREVPOLICYEXPIRYDATE);

/*BEGIN
  lpolextn.PREVPOLICYEFFECTIVEDATE:=TRUNC(to_date(lpolextn.PREVPOLICYEFFECTIVEDATE,'DD/MM/YYYY HH24:MI:SS'));
  EXCEPTION
    WHEN OTHERS THEN
        lpolextn.PREVPOLICYEFFECTIVEDATE:=TRUNC(to_date(lpolextn.PREVPOLICYEFFECTIVEDATE,'DD/MM/YYYY'));
        return;
  END;*/
dbms_output.put_line('lpolextn.PREVPOLICYEFFECTIVEDATE= '||lpolextn.PREVPOLICYEFFECTIVEDATE);
dbms_output.put_line('ncb previous policy validation STARTS');
           ncb_prev_validation :=
                        bjaz_nissan_web_service.ncb_prev_policy_mand (
                           lpolextn.PREVPOLICYNO,
                           trunc(to_date(lpolextn.PREVPOLICYEXPIRYDATE,'MM/DD/YYYY HH24:MI:SS')),
                           TRUNC(to_date(lpolextn.PREVPOLICYEFFECTIVEDATE,'MM/DD/YYYY HH24:MI:SS')),
                           lpolextn.PREVINSURCOMPANYNAME);
dbms_output.put_line('ncb_prev_validation= '||ncb_prev_validation);
dbms_output.put_line('ncb previous policy validation ENDS');


                     IF ncb_prev_validation IS NOT NULL
                     THEN
                        p_error_code := 1;
                        save_error_code (lpol.transactionid,
                                         p_error_code,
                                         ncb_prev_validation);


                        RETURN;
                     END IF;


                     END IF;
dbms_output.put_line('prodcode= '||prodcode);
                    /*   IF prodcode = '1870'
                  THEN                          -- for ST OD LEXUS
dbms_output.put_line('standalone od validation STARTS');
                     st_od_validation :=
                        bjaz_nissan_web_service.ntu_sa_od_validations (
                           lpolextn.PREVPOLICYNO,
                           TRUNC(TO_DATE(lpol.inspolicyeffectivedate,'MM/DD/YYYY HH24:MI:SS')),
                           TRUNC(TO_DATE(lpolextn.PREVPOLICYEXPIRYDATE,'MM/DD/YYYY HH24:MI:SS')),
                           lpolextn.TP_POLICYNUMBER,
                           lpolextn.TP_INSURANCECOMPANY,
                           TRUNC(TO_DATE(lpolextn.instpeffectivedate,'MM/DD/YYYY HH24:MI:SS')),
                           TRUNC(TO_DATE(lpolextn.instpexpirydate,'MM/DD/YYYY HH24:MI:SS')));
dbms_output.put_line('standalone od validation ENDS');
                     IF st_od_validation IS NOT NULL
                     THEN
                        p_error_code := 1;
                        save_error_code (lpol.transactionid,
                                         p_error_code,
                                         st_od_validation);


                        RETURN;
                     END IF;
                  END IF;*/


                IF prodcode = '1870' THEN
dbms_output.put_line('standalone od validation STARTS for prodcode=1870');
                             st_od_validation :=
                             bjaz_nissan_web_service.ntu_sa_od_validations(
                             lpolextn.prevpolicyno,
                             TRUNC(TO_DATE(lpol.inspolicyeffectivedate,'MM/DD/YYYY HH24:MI:SS')),
                             TRUNC(TO_DATE(lpolextn.instpexpirydate,'MM/DD/YYYY HH24:MI:SS')),
                             lpolextn.prevpolicyno,
                             lpolextn.previnsurcompanyname,
                             TRUNC(TO_DATE(lpolextn.instpeffectivedate,'MM/DD/YYYY HH24:MI:SS')),
                             TRUNC(TO_DATE(lpolextn.instpexpirydate,'MM/DD/YYYY HH24:MI:SS')));
dbms_output.put_line('standalone od validation ENDS for prodcode=1870');
                           IF st_od_validation IS NOT  NULL THEN
                                p_error_code := 1;
                                   save_error_code (lpol.transactionid, p_error_code,
                                      st_od_validation);
                           RETURN;
                           END IF;
                      END IF;

                  DBMS_OUTPUT.put_line ('Step 3>>> ' || lpol.transactionid);
                  DBMS_OUTPUT.put_line (   'Step 3>>>v_vehicle_type '
                                        || v_vehicle_type);
                  DBMS_OUTPUT.put_line ('Step 3>>>prodcode ' || prodcode);

                  BEGIN
                     SELECT policy_type, TO_CHAR (broker_code),
                            TO_CHAR (debit_bank_acc_no), sys_user_name
                     INTO   gv_LEXUS_pol_type, gv_LEXUS_imd_code,
                            gv_LEXUS_debit_bank_acc, LEXUS_user_name
                     FROM   bjaz_nissan_broker_dtls
                     WHERE  tieup_name = 'LEXUS';



                   /*   IF UPPER(lpolextn.proposerpaymentmode) IN ('O','L') THEN  \*For call 50320783 by Nitin *\
                        gv_LEXUS_debit_bank_acc := '1072100317';--'1072100365';--

                  ELSIF UPPER(lpolextn.proposerpaymentmode) IN ('C','Z')
                 AND lpolextn.reconciledchequebank ='2088'  AND lpolextn.reconciledchequebranch ='ICICI CC' THEN  \* call no  49578795*\

                gv_LEXUS_debit_bank_acc := '1072100282';--'1072100365';




                       END IF;*/
--gv_LEXUS_debit_bank_acc := '1072100317';
                  EXCEPTION
                     WHEN OTHERS THEN
                        COMMIT;
                        p_error_code := 1;
                        error_comments :=
                           ' TIE-UP NOT CONFIGURED IN BROKER DETAILS. Please check Proposer Payment Mode';--changes for 57420986 - Proper Error message need to provide on interface/report 
                        save_error_code (lpol.transactionid, p_error_code,
                                         error_comments);
                        RETURN;
                  END;

                  DBMS_OUTPUT.put_line ('Step 4>>> ' || lpol.transactionid);
                  DBMS_OUTPUT.put_line (   'Step 4>>> gv_LEXUS_pol_type '
                                        || gv_LEXUS_pol_type);
                  DBMS_OUTPUT.put_line (   'Step 4>>> gv_LEXUS_imd_code '
                                        || gv_LEXUS_imd_code);
                  DBMS_OUTPUT.put_line
                                     (   'Step 4>>> gv_LEXUS_debit_bank_acc '
                                      || gv_LEXUS_debit_bank_acc);
                  DBMS_OUTPUT.put_line (   'Step 4>>> LEXUS_user_name '
                                        || LEXUS_user_name);
                  v_count := 0;
                  v_ques_count := 0;
                  p_error_code := 0;
                  p_error := weo_tyge_error_message_list ();
                  bjaz_ski_part :=
                     bjaz_ski_partner (NULL, NULL, NULL, NULL, NULL, NULL,
                                       NULL, NULL, NULL, NULL, NULL, NULL,
                                       NULL, NULL, NULL, NULL, NULL, NULL,
                                       NULL, NULL, NULL, NULL, NULL, NULL,
                                       NULL, NULL, NULL, NULL);
                  reciept_mst :=
                     bjaz_ski_reciept_mst (NULL, NULL, NULL, NULL, NULL, NULL,
                                           NULL, NULL, NULL, NULL, NULL, NULL);
                  inst_obj :=
                     bjaz_ski_instument (NULL, NULL, NULL, NULL, NULL, NULL,
                                         NULL, NULL, NULL, NULL, NULL);
                  inst_list := bjaz_ski_instument_list ();
                  prod_obj :=
                     bjaz_ski_product (NULL, NULL, NULL, NULL, NULL, NULL,
                                       NULL, NULL, NULL, NULL, NULL, NULL);
                  prod_list := bjaz_ski_product_list ();
                  p_weo_mot_policy_in :=
                     weo_mot_plan_details (NULL, NULL, NULL, NULL, NULL, NULL,
                                           NULL, NULL, NULL, NULL, NULL, NULL,
                                           NULL, NULL, NULL, NULL, NULL, NULL,
                                           NULL, NULL, NULL, NULL, NULL, NULL,
                                           NULL, NULL, NULL, NULL, NULL, NULL,
                                           NULL, NULL, NULL, NULL, NULL, NULL,
                                           NULL, NULL, NULL, NULL, NULL, NULL,
                                           NULL, NULL);
                  accessories_obj :=
                     weo_mot_accessories (NULL, NULL, NULL, NULL, NULL, NULL,
                                          NULL);
                  accessories_list := weo_mot_accessories_list ();
                  paddoncover_obj := weo_mot_gen_param (NULL, NULL);
                  paddoncover_list := weo_mot_gen_param_list ();
                  mot_extra_cover :=
                     weo_sig_mot_extra_covers (NULL, NULL, NULL, NULL, NULL,
                                               NULL, NULL, NULL, NULL, NULL,
                                               NULL, NULL, NULL, NULL, NULL,
                                               NULL, NULL, NULL);
                  phiddenvar :=
                     weo_mot_vechilepage_hidden_var (NULL, NULL, NULL, NULL,
                                                     NULL, NULL, NULL, NULL,
                                                     NULL, NULL, NULL, NULL,
                                                     NULL);
                  p_quest_obj := weo_bjaz_mot_questionary (NULL, NULL, NULL);
                  p_quest_list := weo_bjaz_mot_quest_list ();
                  premium_details_out :=
                     weo_mot_premium_details (NULL, NULL, NULL, NULL, NULL,
                                              NULL, NULL, NULL, NULL, NULL,
                                              NULL, NULL, NULL, NULL);
                  premium_summery_obj :=
                     weo_mot_premium_summary (NULL, NULL, NULL, NULL, NULL,
                                              NULL);
                  premium_summery_list := weo_mot_premium_summary_list ();
                  geog_extn := NULL;
                  p_rcpt_obj :=
                     weo_tyac_pay_row (NULL, NULL, NULL, NULL, NULL, NULL,
                                       NULL, NULL, NULL, NULL, NULL, NULL,
                                       NULL, NULL, NULL, NULL, NULL, NULL,
                                       NULL, NULL, NULL, NULL);
                  p_rcpt_list := weo_tyac_pay_list ();
                  p_cust_details :=
                     weo_b2c_cust_details (NULL, NULL, NULL, NULL, NULL, NULL,
                                           NULL, NULL, NULL, NULL, NULL, NULL,
                                           NULL, NULL, NULL, NULL, NULL, NULL,
                                           NULL, NULL, NULL, NULL, NULL, NULL,
                                           NULL, NULL, NULL, NULL, NULL, NULL,
                                           NULL, NULL, NULL, NULL);
                  ppolicyref := NULL;
                  ppolicyissuedate := NULL;
                  ppart_id := NULL;
                  ppremiumpayerid := NULL;
                  paymentmode := NULL;
                  locationid := NULL;
                  potherdetails :=
                     weo_sig_other_details (NULL, NULL, NULL, NULL, NULL,
                                            NULL, NULL, NULL, NULL, NULL);
                  p_instrument_type := NULL;
                  v_count := 0;
                  p_error_code := 0;
                  p_error := weo_tyge_error_message_list ();
                  gv_LEXUS_basic_od_prem := NULL;
                  gv_LEXUS_basic_od_prem := lpol.basicodp;
                  gvx_LEXUS_vehicle_od := NULL;
                  gvx_LEXUS_vehicle_od :=
                     ROUND (  (NVL (lpol.basicodp, 0))
                            - (  NVL (lpol.nonelectricaccpremium, 0)
                               + NVL (lpol.electricaccpremium, 0)
                               + NVL (lpol.bifuelkitpremium, 0)
                              ));
                  DBMS_OUTPUT.put_line (   'Step 5>>> '
                                        || 'Partner creation starts');

                  /*START: CREATE PARTNER*/
                  IF NVL (lpol.proposertype, NULL) = 'I' THEN
                     partner_type := 'P';
                     insured_name :=
                           NVL (lpol.firstname, NULL)
                        || ' '
                        || NVL (lpol.middlename, NULL)
                        || ' '
                        || NVL (lpol.lastname, NULL);
                  ELSIF NVL (lpol.proposertype, NULL) = 'C' THEN
                     partner_type := 'I';
                     insured_name := NVL (lpol.companyname, NULL);
                  END IF;

                  DBMS_OUTPUT.put_line ('Step 6>>> Partner>> 1');

                  IF LENGTH (NVL (lpol.address1, NULL)) > 100 THEN
                     address1 := SUBSTR (lpol.address1, 1, 100);
                  ELSE
                     address1 := SUBSTR (lpol.address1, 1, 100);
                  END IF;

                  IF LENGTH (NVL (lpol.address2, NULL)) > 100 THEN
                     address2 := SUBSTR (lpol.address2, 1, 100);
                  ELSE
                     address2 := SUBSTR (lpol.address2, 1, 100);
                  END IF;

                  IF lpol.address3 IS NOT NULL THEN
                     address2 := SUBSTR (address2 || lpol.address3, 1, 100);
                  ELSE
                     address2 := address2;
                  END IF;

                  IF address1 IS NULL THEN
                     address1 := '-';
                  END IF;

                  DBMS_OUTPUT.put_line ('Step 6>>> Partner>> 2');

                  <<block_9>>
                  BEGIN
                     SELECT bjaz_subimd
                     INTO   mot_extra_cover.sub_imdcode
                     FROM   bjaz_mibl_dealermast_dtls
                     WHERE  dealer_code = lpol.inspolicyissuingdealercode
                            AND top_indicator = 'Y' AND tieup = 'LEXUS';
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_error_code := 1;
                        error_comments :=
                              'SUB IMD CODE NOT MENTIONED '
                           || lpol.inspolicyissuingdealercode;
                        save_error_code (lpol.transactionid, p_error_code,
                                         error_comments);
                        COMMIT;
                        RETURN;
                  END block_9;

                  DBMS_OUTPUT.put_line
                                     (   'Step 6>>> Partner>> 2 sub-imd name '
                                      || mot_extra_cover.sub_imdcode);
                  gv_LEXUS_subimd_code := mot_extra_cover.sub_imdcode;

                  BEGIN
                     SELECT city_name,
                            (SELECT state_name
                             FROM   bjaz_mibl_state_dtls
                             WHERE  state_code = x.state_code
                                    AND tieup = 'LEXUS')
                     INTO   v_cityname,
                            v_statename
                     FROM   bjaz_mibl_city_dtls x
                     WHERE  city_code = lpol.citycode AND top_indicator = 'Y'
                            AND tieup = 'LEXUS';
                  EXCEPTION
                     WHEN OTHERS THEN
                        COMMIT;
                        p_error_code := 1;
                        error_comments :=
                                     'CITY CODE AND STATE CODE NOT MENTIONED';
                        save_error_code (lpol.transactionid, p_error_code,
                                         error_comments);
                        COMMIT;
                        RETURN;
                  END block_1;

                  DBMS_OUTPUT.put_line (   'Step 6>>> Partner>> state name '
                                        || v_statename);
                  DBMS_OUTPUT.put_line (   'Step 6>>> Partner>> city name '
                                        || v_cityname);
                  bjaz_ski_part.partner_type := partner_type;
                  bjaz_ski_part.address_line1 := NVL (address1, '-');
                  bjaz_ski_part.address_line2 := NVL (address2, '-');
                  bjaz_ski_part.city := NVL (v_cityname, NULL);
                  bjaz_ski_part.state := NVL (v_statename, NULL);
                  bjaz_ski_part.landmark := NULL;
                  bjaz_ski_part.area := NULL;
                  bjaz_ski_part.pin_code := NVL (lpol.pincode, NULL);
                  bjaz_ski_part.telephone := NULL;
                  bjaz_ski_part.telephone2 := NULL;
                  bjaz_ski_part.moblie_no := NULL;
                  bjaz_ski_part.email := NULL;
                  bjaz_ski_part.before_title := NVL (lpol.salutation, NULL);

                  IF NVL (lpol.proposertype, NULL) = 'C' THEN
                     bjaz_ski_part.first_name := NVL (lpol.companyname, NULL);
                  ELSE
                     bjaz_ski_part.first_name := NVL (lpol.firstname, NULL);
                     bjaz_ski_part.middle_name := NVL (lpol.middlename, NULL);
                     bjaz_ski_part.sur_name := NVL (lpol.lastname, NULL);
                  END IF;

                  bjaz_ski_part.sex := NULL;
                  bjaz_ski_part.date_of_birth := NULL;
                  bjaz_ski_part.parent_co := NULL;
                  bjaz_ski_part.parent_id := NULL;

                  IF NVL (lpol.proposertype, NULL) = 'C' THEN
                     bjaz_ski_part.institution_name :=
                                                 NVL (lpol.companyname, NULL);
                  END IF;

                  bjaz_ski_part.reg_no := NULL;
                  bjaz_ski_part.addressee := SUBSTR (lpol.address1, 1, 60);
                  bjaz_ski_part.p_buisness := 'NB';
                  bjaz_ski_part.ski_part_id := lpol.transactionid;
                  DBMS_OUTPUT.put_line ('Step 6>>> before calling add_parner');

                  IF p_error_code = 0 THEN
                     customER.BJAZ_LEXUS_WEBSERVICE.add_partner
                                                              (bjaz_ski_part,
                                                               p_error,
                                                               p_error_code);
                  END IF;

                  DBMS_OUTPUT.put_line (   'Step 6>>> partner_id created '
                                        || bjaz_ski_part.bjaz_part_id);

                  IF p_error_code = 0 THEN
                     COMMIT;
                  ELSE
                     COMMIT;
                     p_error_code := 1;
                     error_comments := 'EXCEPTION IN CREATING PARTNER ';
                     save_error_code (lpol.transactionid, p_error_code,
                                      error_comments);
                     RETURN;
                  END IF;

                  IF lpolextn.buyergstin IS NOT NULL THEN
                     BEGIN
                        SELECT SUBSTR (lpolextn.buyergstin, 3, 10)
                        INTO   v_pannumber
                        FROM   DUAL;
                     EXCEPTION
                        WHEN OTHERS THEN
                           v_pannumber := NULL;
                     END;

                     UPDATE bjaz_LEXUS_ws_data_extn
                     SET pancardnumber = v_pannumber
                     WHERE  transactionid = lpol.transactionid;

                     COMMIT;
                  END IF;

                  /*END: CREATE PARTNER*/
                  DBMS_OUTPUT.put_line ('Step 7 >> validating GST');

                  IF lpolextn.buyergstin IS NOT NULL THEN
                     BEGIN
                        bjaz_marsh_utils.validate_gstn_details
                                                 (bjaz_ski_part.bjaz_part_id,
                                                  lpolextn.buyergstin,
                                                  lpol.pincode,
                                                  lpolextn.pancardnumber,
                                                  error_comments);

                        IF error_comments <> 'VALID' THEN
                           p_error_code := 0;
                           save_error_code (lpol.transactionid, p_error_code,
                                            error_comments);
                        END IF;
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_error_code := 0;
                           error_comments :=
                                 error_comments
                              || ' EXCEPTION FOUND WHILE GST VALIDATIONS ';
                           save_error_code (lpol.transactionid, p_error_code,
                                            error_comments);
                     END;
                  END IF;

                  v_compare_prem := lpolextn.grosspremium;
                  v_chequeno := lpolextn.reconciledchequeno;
                  v_unique_ref_no := lpolextn.uniquerefnumber;
                  DBMS_OUTPUT.put_line
                                 ('Step 7 >> validating GST -- Success -- GST');

                  <<block_3>>
                  BEGIN
                     IF lpolextn.reconciledchequeissuedby = 'D' THEN
                        SELECT NVL ((reconciledchequeamount), 0)
                        INTO   v_total_chequeamount
                        FROM   bjaz_LEXUS_ws_data a,
                               bjaz_LEXUS_ws_data_extn b
                        WHERE  reconciledchequeno = v_chequeno
                               AND reconciledchequebank =
                                                     lpolextn.reconciledchequebank
                               AND reconciledchequeissuedby = 'D'
                               AND a.transactionid = lpol.transactionid
                               AND a.transactionid = b.transactionid
                               AND TRUNC (last_uploaddate) =
                                     (SELECT TRUNC (last_uploaddate)
                                      FROM   bjaz_LEXUS_ws_data
                                      WHERE  transactionid =lpol.transactionid)
                                AND a.transactionid = lpol.transactionid;

                        DBMS_OUTPUT.put_line
                                    (   'Step 8 >> validating checque amount '
                                     || v_total_chequeamount);

                        SELECT COUNT (a.transactionid)
                        INTO   v_cnt_covernote
                        FROM   bjaz_LEXUS_ws_data a,
                               bjaz_LEXUS_ws_data_extn b
                        WHERE  reconciledchequeno = v_chequeno
                               AND reconciledchequebank =
                                                     lpolextn.reconciledchequebank
                               AND reconciledchequeissuedby = 'D'
                               AND a.transactionid = lpol.transactionid
                               AND a.transactionid = b.transactionid
                               AND TRUNC (last_uploaddate) =
                                     (SELECT TRUNC (last_uploaddate)
                                      FROM   bjaz_LEXUS_ws_data
                                      WHERE  transactionid =lpol.transactionid)
                              AND a.transactionid = lpol.transactionid;

                        DBMS_OUTPUT.put_line
                                   (   'Step 8 >> validating v_cnt_covernote '
                                    || v_cnt_covernote);
                     ELSE
                        SELECT NVL (SUM (reconciledchequeamount), 0)
                        INTO   v_total_chequeamount
                        FROM   bjaz_LEXUS_ws_data a,
                               bjaz_LEXUS_ws_data_extn b
                        WHERE  b.uniquerefnumber = v_unique_ref_no
                               AND a.transactionid = b.transactionid
                               AND a.transactionid = lpol.transactionid
                               AND TRUNC (last_uploaddate) =
                                     (SELECT TRUNC (last_uploaddate)
                                      FROM   bjaz_LEXUS_ws_data
                                      WHERE  transactionid =
                                                            lpol.transactionid);

                        DBMS_OUTPUT.put_line
                               (   'Step 8 >> validating checque amount else '
                                || v_total_chequeamount);

                        SELECT COUNT (a.transactionid)
                        INTO   v_cnt_covernote
                        FROM   bjaz_LEXUS_ws_data a,
                               bjaz_LEXUS_ws_data_extn b
                        WHERE  b.uniquerefnumber = v_unique_ref_no
                               AND a.transactionid = b.transactionid
                               AND a.transactionid = lpol.transactionid
                               AND TRUNC (last_uploaddate) =
                                     (SELECT TRUNC (last_uploaddate)
                                      FROM   bjaz_LEXUS_ws_data
                                      WHERE  transactionid =
                                                            lpol.transactionid);

                        DBMS_OUTPUT.put_line
                               (   'Step 8 >> validating v_cnt_covernote else'
                                || v_cnt_covernote);
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                        v_total_chequeamount := '0';
                  END block_3;

                  DBMS_OUTPUT.put_line
                                  ('Step 9 >> premium calculation part starts');

                  /*Start:-Calculate Premium*/
                  BEGIN
                     IF NVL (lpol.financercode, 0) = 0 THEN
                        financed_type := 0;
                     ELSE
                        financed_type := 1;
                     END IF;

                 IF TRIM (lpolextn.previnsurcompanyname) IS NOT NULL THEN
                  BEGIN
                     SELECT company_code
                     INTO   v_prv_comp_code
                     FROM   bjaz_dealer_ins_comp
                     WHERE  UPPER (insurance_co_name) LIKE
                               TRIM (UPPER ('%' || lpolextn.previnsurcompanyname
                                            || '%'))
                                    AND TIEUP_NAME IN ('ALL','LEXUS_SYS');     --For call 50738259 by Nitin
                  EXCEPTION
                     WHEN TOO_MANY_ROWS THEN
                        SELECT company_code
                     INTO   v_prv_comp_code
                     FROM   bjaz_dealer_ins_comp
                     WHERE  UPPER (insurance_co_name) LIKE
                               TRIM (UPPER ('%' || lpolextn.previnsurcompanyname
                                            || '%'))
                                    AND TIEUP_NAME IN ('LEXUS_SYS');

                     WHEN OTHERS THEN
                        v_prv_comp_code := NULL;
                  END;
               END IF;

                     IF lpolextn.previnsurcompanyname IS NOT NULL THEN
                        prvinscompany := v_prv_comp_code ;                      --For call 50738259 by Nitin
                     ELSE
                        prvinscompany := NULL;
                     END IF;


                     DBMS_OUTPUT.put_line (   'Step 9 >> financed_type '
                                           || financed_type);

                     <<block_4>>
                     DECLARE
                        v_vehicle_make      bjaz_vehicle_make_master.vehicle_make%TYPE;
                        v_vehicle_model     bjaz_vehicle_model_master.vehicle_model%TYPE;
                        v_vehicle_subtype   bjaz_vehicle_model_master.vehicle_subtype%TYPE;
                     BEGIN
                        SELECT vehicle_type_code, vehicle_make_code,
                               vehicle_model_code, vehicle_subtype_code,
                               NVL (misc_veh_type_code, 0), fuel
                        INTO   vehicletypecode, vehiclemakecode,
                               vehiclemodelcode, vehiclesubtypecode,
                               miscvehtypecode, p_fuel_name
                        FROM   bjaz_vehicle_model_master
                        WHERE  vehicle_code = lpol.bjaz_veh_code
                               -- AND status = 1 /* As per Pankaj Jain Sir approval declained Vehicle for LEXUS FORTUNER is opening only in LEXUS Web Service */
                               AND vehicle_type_code IN
                                                 (22, 23, 24, 25, 27, 28, 29,41,42,43,44)
                               AND fuel IS NOT NULL;

                        DBMS_OUTPUT.put_line (   'Step 9 >> vehicletypecode '
                                              || vehicletypecode);
                        DBMS_OUTPUT.put_line (   'Step 9 >> vehiclemakecode '
                                              || vehiclemakecode);
                        DBMS_OUTPUT.put_line (   'Step 9 >> vehiclemodelcode '
                                              || vehiclemodelcode);
                        DBMS_OUTPUT.put_line
                                           (   'Step 9 >> vehiclesubtypecode '
                                            || vehiclesubtypecode);
                        DBMS_OUTPUT.put_line (   'Step 9 >> miscvehtypecode '
                                              || miscvehtypecode);
                        DBMS_OUTPUT.put_line (   'Step 9 >> p_fuel_name '
                                              || p_fuel_name);

                        SELECT DISTINCT vehicle_make
                        INTO            v_vehicle_make
                        FROM            bjaz_vehicle_make_master
                        WHERE           vehicle_make_code = vehiclemakecode
                                        AND vehicle_type_code =
                                                               vehicletypecode;

                        DBMS_OUTPUT.put_line (   'Step 9 >> v_vehicle_make '
                                              || v_vehicle_make);

                        IF p_fuel_name = 'PETROL' OR p_fuel_name = 'PETROLEUM' THEN
                           p_fuel_name := 'P';
                        ELSIF p_fuel_name = 'DIESEL' THEN
                           p_fuel_name := 'D';
                        ELSIF p_fuel_name = 'CNG' THEN
                           p_fuel_name := 'C';
                        ELSIF p_fuel_name = 'BIOFUEL' OR p_fuel_name like 'B%' THEN
                           p_fuel_name := 'B';
                        ELSE
                           p_fuel_name := p_fuel_name;
                        END IF;

                        DBMS_OUTPUT.put_line (   'Step 9 >> p_fuel_name '
                                              || p_fuel_name);


                       /* UPDATE bjaz_LEXUS_ws_data
                        SET fueltype = p_fuel_name
                        WHERE  transactionid = lpol.transactionid;

            COMMIT;*/

                        SELECT DISTINCT vehicle_model, vehicle_subtype
                        INTO            v_vehicle_model, v_vehicle_subtype
                        FROM            bjaz_vehicle_model_master
                        WHERE           vehicle_model_code = vehiclemodelcode
                                        AND vehicle_make_code =
                                                               vehiclemakecode
                                        AND vehicle_type_code =
                                                               vehicletypecode
                                        AND vehicle_subtype_code =
                                                            vehiclesubtypecode;
                     EXCEPTION
                        WHEN OTHERS THEN
                           BEGIN
                              SELECT vehicle_type_code, vehicle_make_code,
                                     vehicle_model_code,
                                     vehicle_subtype_code,
                                     NVL (misc_veh_type_code, 0), fuel
                              INTO   vehicletypecode, vehiclemakecode,
                                     vehiclemodelcode,
                                     vehiclesubtypecode,
                                     miscvehtypecode, p_fuel_name
                              FROM   bjaz_vehicle_model_master
                              WHERE  vehicle_code = lpol.bjaz_veh_code
                                     AND status = 1
                                     AND vehicle_type_code IN
                                                 (22, 23, 24, 25, 27, 28, 29,41,42,43,44)
                                     AND fuel IS NOT NULL;
                           EXCEPTION
                              WHEN OTHERS THEN
                                 vehicletypecode := NULL;
                                 vehiclemakecode := NULL;
                                 vehiclemodelcode := NULL;
                                 vehiclesubtypecode := NULL;
                                 p_error_code := 1;
                                 COMMIT;
                                 error_comments :=
                                       'DATA NOT FOUND IN VEHICLE DETAIL '
                                    || lpol.bjaz_veh_code;
                                 save_error_code (lpol.transactionid,
                                                  p_error_code,
                                                  error_comments);
                                 RETURN;
                           END;
                     END block_4;

                     DBMS_OUTPUT.put_line ('Step 9 >> after vehicle details');
                     pidvvalue := lpol.vehicleidv;
                     p_weo_mot_policy_in.contract_id := NULL;
                     p_weo_mot_policy_in.pol_type := gv_LEXUS_pol_type;
                     p_weo_mot_policy_in.product_4digit_code := prodcode;
                     p_weo_mot_policy_in.dept_code := 18;
                     p_weo_mot_policy_in.branch_code := lpol.bjaz_loc_code;
DBMS_OUTPUT.PUT_LINE('p_weo_mot_policy_in.dept_code= '||p_weo_mot_policy_in.dept_code);
DBMS_OUTPUT.PUT_LINE('p_weo_mot_policy_in.branch_code= '||p_weo_mot_policy_in.branch_code);
                     p_weo_mot_policy_in.term_start_date :=
                          TO_CHAR(TRUNC(TO_DATE(lpol.inspolicyeffectivedate, 'MM/DD/ HH24:MI:SS')),'DD-MON-YYYY');
                     p_weo_mot_policy_in.term_end_date :=
                             TO_CHAR(TRUNC(TO_DATE(lpol.inspolicyexpirydate, 'MM/DD/YYYY HH24:MI:SS')),'DD-MON-YYYY');
                     p_weo_mot_policy_in.tp_fin_type := financed_type;
DBMS_OUTPUT.PUT_LINE('WEO_MOT_UTIL p_weo_mot_policy_in.term_start_date= '||p_weo_mot_policy_in.term_start_date);
DBMS_OUTPUT.PUT_LINE('p_weo_mot_policy_in.term_end_date= '||p_weo_mot_policy_in.term_end_date);
                     IF financed_type = 1 THEN

                        <<block_5>>
                        DECLARE
                           vfinname   VARCHAR2 (150);
                        BEGIN
                           SELECT financer_name
                           INTO   vfinname
                           FROM   bjaz_mibl_fin_dtls
                           WHERE  financer_code = lpol.financercode
                                  AND tieup = 'LEXUS';

                           p_weo_mot_policy_in.hypo := vfinname;
                        EXCEPTION
                           WHEN OTHERS THEN
                              COMMIT;
                              p_error_code := 1;
                              error_comments := 'FINANCER NAME IS NOT FOUND.';
                              save_error_code (lpol.transactionid,
                                               p_error_code, error_comments);
                              RETURN;
                        END block_5;
                     ELSE
                        p_weo_mot_policy_in.hypo := NULL;
                     END IF;

                     DBMS_OUTPUT.put_line (   'Step 9 >> Fianace Name '
                                           || p_weo_mot_policy_in.hypo);
                     p_weo_mot_policy_in.vehicle_model_code :=
                                                              vehiclemodelcode;
                     p_weo_mot_policy_in.vehicle_subtype_code :=
                                                            vehiclesubtypecode;

                     <<block_6>>
                     DECLARE
                        v_subtype    VARCHAR2 (100);
                        v_model      VARCHAR2 (100);
                        v_fueltype   VARCHAR2 (50);
                     BEGIN
                        IF p_fuel_name = 'P' THEN
                           v_fueltype := 'PETROL';
                        ELSIF p_fuel_name = 'D' THEN
                           v_fueltype := 'DIESEL';
                        ELSIF p_fuel_name = 'C' THEN
                           v_fueltype := 'CNG';
                        ELSIF p_fuel_name = 'B' THEN
                           v_fueltype := 'BIOFUEL';
                        ELSIF p_fuel_name LIKE '%H%' THEN
                          v_fueltype := 'HYBRID';
                        ELSE
                           v_fueltype := p_fuel_name;
                        END IF;

                        SELECT variant_name, model_name,
                               veh_type
                        INTO   v_subtype, v_model,
                               p_weo_mot_policy_in.vehicle_type
                        FROM   bjaz_mibl_variant_dtls x
                        WHERE  variant_code = lpol.variantcode
                               AND veh_type = lpol.vehicleclass
                               AND fuel_type = v_fueltype
                               AND top_indicator = 'Y' AND tieup = 'LEXUS';

                        p_weo_mot_policy_in.vehicle_model :=
                                                           NVL (v_model, NULL);
                        p_weo_mot_policy_in.vehicle_subtype :=
                                                         NVL (v_subtype, NULL);
                     EXCEPTION
                        WHEN OTHERS THEN
                           COMMIT;
                           p_error_code := 1;
                           error_comments :=
                                   'VARIANT CODE & MODEL NAME IS NOT FOUND. ';
                           save_error_code (lpol.transactionid, p_error_code,
                                            error_comments);
                           RETURN;
                     END block_6;
IF p_fuel_name LIKE '%H%' THEN
  p_fuel_name:='H';
  END IF;
                     p_weo_mot_policy_in.vehicle_type_code := vehicletypecode;
                     p_weo_mot_policy_in.misc_veh_type := miscvehtypecode;
                     p_weo_mot_policy_in.vehicle_make_code := vehiclemakecode;
                     p_weo_mot_policy_in.vehicle_make := 'LEXUS';
                     p_weo_mot_policy_in.fuel := p_fuel_name;

                     BEGIN
                        SELECT tzone_private
                        INTO   v_tzone_private
                        FROM   bjaz_mibl_city_dtls
                        WHERE  city_code = lpol.citycode AND tieup = 'LEXUS'
                               AND top_indicator = 'Y';
                     EXCEPTION
                        WHEN OTHERS THEN
                           v_tzone_private := NULL;
                     END;

                     p_weo_mot_policy_in.ZONE := v_tzone_private;
                     DBMS_OUTPUT.put_line
                            (   'Step 9 >> p_weo_mot_policy_in.vehicle_model '
                             || p_weo_mot_policy_in.vehicle_model);
                     DBMS_OUTPUT.put_line
                          (   'Step 9 >> p_weo_mot_policy_in.vehicle_subtype '
                           || p_weo_mot_policy_in.vehicle_subtype);

                     <<block_8>>
                     DECLARE
                        v_rtoname   VARCHAR2 (150);
                     BEGIN
                        SELECT rto_name
                        INTO   v_rtoname
                        FROM   bjaz_mibl_rto_dtls
                        WHERE  rto_code = lpol.rtocode AND top_indicator = 'Y'
                               AND tieup = 'LEXUS';

                        p_weo_mot_policy_in.registration_location :=
                                                         NVL (v_rtoname, NULL);
                     EXCEPTION
                        WHEN OTHERS THEN
                           COMMIT;
                           p_error_code := 1;
                           error_comments := 'RTO NAME IS NOT FOUND. ';
                           save_error_code (lpol.transactionid, p_error_code,
                                            error_comments);
                           error_comments := NULL;
                           RETURN;
                     END block_8;
dbms_output.put_line('v_rtoname ');
                     BEGIN
                        IF ba_motor_validations.other_pol_exist_with_same_dtls
                                    (NVL (UPPER (lpol.registrationno), 'NEW'),
                                     lpol.engineno, lpol.chassisno,
                                     p_weo_mot_policy_in.term_start_date,
                                     p_weo_mot_policy_in.term_end_date,
                                     p_weo_mot_policy_in.product_4digit_code,
                                     v_policy_ref) THEN
                           IF v_policy_ref <> 'X' THEN
                              COMMIT;
                              p_error_code := 1;
                              error_comments :=
                                 'Policy Already Issued With Same Registration/Engine/Chassis Number.';
                              save_error_code (lpol.transactionid,
                                               p_error_code, error_comments);
                              error_comments := NULL;
                              RETURN;
                           END IF;
                        END IF;
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_error_code := 1;
                           error_comments :=
                              'Exception When Validating The Registration/Engine/Chassis Number. ';
                           save_error_code (lpol.transactionid, p_error_code,
                                            error_comments);
                           error_comments := NULL;
                     END;

            --added by sandip 47828311
                 IF NVL (bjaz_utils.get_param_value ('REGNULDLR', 18,prodcode,SYSDATE),0) = 1
                      THEN
                     error_comments := bjaz_mibl_web_service.check_regno_ntu(lpol.registrationno, lpol.inspolicytype);
                               IF error_comments <> 'X'
                                   THEN
                                       p_error_code := 1;
                    COMMIT;
                                       save_error_code (lpol.transactionid, p_error_code,
                                                                 error_comments);
                                        COMMIT;
                    error_comments := NULL;
                                        RETURN;
                               END IF;
                 END IF;


                     DBMS_OUTPUT.put_line
                        (   'Step 9 >> p_weo_mot_policy_in.registration_location '
                         || p_weo_mot_policy_in.registration_location);
                     p_weo_mot_policy_in.engine_no :=
                                                     NVL (lpol.engineno, NULL);
                     p_weo_mot_policy_in.chassis_no :=
                                                    NVL (lpol.chassisno, NULL);
                     p_weo_mot_policy_in.registration_no :=
                                               NVL (lpol.registrationno, NULL);
                     p_weo_mot_policy_in.registration_date :=
                        NVL (TO_CHAR(TRUNC(TO_DATE(lpol.vehicleinvoicedate, 'MM/DD/YYYY HH24:MI:SS')),'DD-MON-YYYY'),
                             TO_CHAR(TRUNC(TO_DATE(lpol.vehicleinvoicedate,'MM/DD/YYYY HH24:MI:SS')),'DD-MON-YYYY'));
                     p_weo_mot_policy_in.regi_loc_other := NULL;

                     IF lpol.vehicleclass = 'C' THEN
                        p_weo_mot_policy_in.carrying_capacity :=
                                                NVL (lpol.seatingcapacity, 0);

                        IF p_weo_mot_policy_in.carrying_capacity <> 0 THEN
                           p_weo_mot_policy_in.carrying_capacity :=
                                    p_weo_mot_policy_in.carrying_capacity - 1;
                        END IF;
                     ELSE
                        p_weo_mot_policy_in.carrying_capacity :=
                                                NVL (lpol.seatingcapacity, 0);
                     END IF;

                     p_weo_mot_policy_in.cubic_capacity := lpol.cc;
                     p_weo_mot_policy_in.year_manf :=
                                            NVL (lpol.yearofmanufacture, NULL);
                     p_weo_mot_policy_in.color := NULL;
                     p_weo_mot_policy_in.vehicle_idv :=
                                                      NVL (lpol.vehicleidv, 0);
                     p_weo_mot_policy_in.ncb := NVL (lpol.ncbper, 0);
                     p_weo_mot_policy_in.add_loading := NULL;
                     p_weo_mot_policy_in.add_loading_on := NULL;
                     p_weo_mot_policy_in.sp_disc_rate := NULL;
                     p_weo_mot_policy_in.elec_acc_total :=
                                                  NVL (lpol.electricaccidv, 0);
                     p_weo_mot_policy_in.non_elec_acc_total :=
                                               NVL (lpol.nonelectricaccidv, 0);

                      IF lpolextn.previnsurcompanyname IS NOT NULL THEN

                prvinscompany := v_prv_comp_code ;                           --For call 50738259 by Nitin
                        p_weo_mot_policy_in.prv_policy_ref :=
                                            NVL (lpolextn.prevpolicyno, NULL);
                        p_weo_mot_policy_in.prv_expiry_date :=
                                                TO_CHAR(TO_DATE(lpolextn.prevpolicyexpirydate,'MM/DD/YYYY'),'DD-MON-YYYY');
                        p_weo_mot_policy_in.prv_ins_company := prvinscompany ;                 --For call 50738259 by Nitin
                        p_weo_mot_policy_in.prv_ncb := NVL (lpol.ncbper, 0);
                        p_weo_mot_policy_in.prv_claim_status := 0;
                     ELSE
                        p_weo_mot_policy_in.prv_policy_ref := NVL (lpolextn.prevpolicyno, NULL);
                        p_weo_mot_policy_in.prv_expiry_date := TO_CHAR(TO_DATE(lpolextn.prevpolicyexpirydate,'MM/DD/YYYY'),'DD-MON-YYYY');
                        p_weo_mot_policy_in.prv_ins_company := NULL;
                        p_weo_mot_policy_in.prv_ncb := NVL (lpol.ncbper, 0);
                        p_weo_mot_policy_in.prv_claim_status := 0;
                     END IF;

                     IF lpol.isaamembership = 1 THEN
                        p_weo_mot_policy_in.auto_membership := 1;
                     ELSE
                        p_weo_mot_policy_in.auto_membership := NULL;
                     END IF;

                     p_weo_mot_policy_in.partner_type := partner_type;

                     IF NVL (lpolextn.imt23premium, 0) > 0 THEN
                        v_count := v_count + 1;
                        paddoncover_list.EXTEND ();
                        paddoncover_list (v_count) :=
                                         weo_mot_gen_param ('IMT23', 'IMT23');
                     END IF;

                     IF NVL (lpolextn.imt44premium, 0) > 0 THEN
                        v_count := v_count + 1;
                        paddoncover_list.EXTEND ();
                        paddoncover_list (v_count) :=
                                         weo_mot_gen_param ('IMT44', 'IMT44');
                     END IF;

                     IF NVL (lpol.geographicextnpremiumod, 0) > 0 THEN
                        v_count := v_count + 1;
                        paddoncover_list.EXTEND ();
                        paddoncover_list (v_count) :=
                                           weo_mot_gen_param ('GEOG', 'GEOG');

                        IF lpol.isbhutancovered = 1 THEN
                           geog_extn := 'BHUTAN';
                        ELSIF lpol.isnepalcovered = 1 THEN
                           IF geog_extn IS NULL THEN
                              geog_extn := 'NEPAL';
                           ELSE
                              geog_extn := geog_extn || 'NEPAL,';
                           END IF;
                        ELSIF lpol.isbangladeshcovered = 1 THEN
                           IF geog_extn IS NULL THEN
                              geog_extn := 'BANGLADESH';
                           ELSE
                              geog_extn := geog_extn || 'BANGLADESH,';
                           END IF;
                        ELSIF lpol.ismaldivescovered = 1 THEN
                           IF geog_extn IS NULL THEN
                              geog_extn := 'MALDIVES';
                           ELSE
                              geog_extn := geog_extn || 'MALDIVES,';
                           END IF;
                        ELSIF lpol.issrilankacovered = 1 THEN
                           IF geog_extn IS NULL THEN
                              geog_extn := 'SRILANKA';
                           ELSE
                              geog_extn := geog_extn || 'SRILANKA,';
                           END IF;
                        ELSIF lpol.ispakistancovered = 1 THEN
                           IF geog_extn IS NULL THEN
                              geog_extn := 'PAKISTAN';
                           ELSE
                              geog_extn := geog_extn || 'PAKISTAN,';
                           END IF;
                        END IF;
                     END IF;

                     gv_LEXUS_cng_inbuilt := 'N';

              IF prodcode = '1801' THEN
                         v_tpcurrent_policy_tenure := 1;
                     ELSE
                     BEGIN
                        SELECT NVL (DECODE (longtermpolicy, 2, 3, 1, 1), 1)
                        INTO   v_tpcurrent_policy_tenure
                        FROM   bjaz_LEXUS_ws_data_extn
                        WHERE  transactionid = lpol.transactionid;
                     EXCEPTION
                        WHEN OTHERS THEN
                           v_tpcurrent_policy_tenure := 1;
                     END;
             END IF;

                     IF NVL (lpol.bifueltppremium, 0) = 60 THEN
                        v_count := v_count + 1;
                        paddoncover_list.EXTEND ();
                        paddoncover_list (v_count) :=
                                             weo_mot_gen_param ('CNG', 'CNG');
                        mot_extra_cover.cng_value :=
                                                   NVL (lpol.bifuelkitidv, 0);

                        IF TO_NUMBER (lpol.bifuelkitidv) > 0 THEN
                           NULL;
                        ELSE
                           gv_LEXUS_cng_inbuilt := 'Y';
                        END IF;
                     END IF;

                     IF lpol.isantitheftattached = 1 THEN
                        v_count := v_count + 1;
                        paddoncover_list.EXTEND ();
                        paddoncover_list (v_count) :=
                                       weo_mot_gen_param ('ATHEFT', 'ATHEFT');
                     END IF;

                     mot_extra_cover.voluntary_excess := 0;

                     IF NVL (lpol.voluntarydeductible, 0) > 0 THEN
                        v_count := v_count + 1;
                        paddoncover_list.EXTEND ();
                        paddoncover_list (v_count) :=
                                         weo_mot_gen_param ('VOLEX', 'VOLEX');
                        mot_extra_cover.voluntary_excess :=
                                            NVL (lpol.voluntarydeductible, 0);
                     END IF;

                     IF NVL (lpolextn.exttppd, 0) = 6000 THEN
                        v_count := v_count + 1;
                        paddoncover_list.EXTEND ();
                        paddoncover_list (v_count) :=
                                   weo_mot_gen_param ('TPPD_RES', 'TPPD_RES');
                     END IF;

                     IF NVL (lpolextn.panoofperson, 0) > 0 THEN
                        v_count := v_count + 1;
                        paddoncover_list.EXTEND ();
                        paddoncover_list (v_count) :=
                                               weo_mot_gen_param ('PA', 'PA');
                        mot_extra_cover.no_of_persons_pa :=
                                                   NVL (lpolextn.panoofperson, 0);
                        mot_extra_cover.sum_insured_pa :=
                                                   lpolextn.pasuminsuredperperson;
                        mot_extra_cover.sum_insured_total_named_pa := 0;
                     END IF;

                     IF NVL (lpolextn.ispapaiddriver, 0) = 1 THEN
                        v_count := v_count + 1;
                        paddoncover_list.EXTEND ();
                        paddoncover_list (v_count) :=
                                         weo_mot_gen_param ('PA_PD', 'PA_PD');
                        mot_extra_cover.extra_field1 := 1;
                        v_paprem := NVL (lpolextn.pacoverprempaiddriver, 0);

                        IF lpol.vehicleclass = 'C' THEN
                           mot_extra_cover.extra_field2 :=
                                                 NVL (v_paprem, 0) * 10000
                                                 / 6;
                        ELSE
                           mot_extra_cover.extra_field2 :=
                                                 NVL (v_paprem, 0) * 10000
                                                 / 5;
                        END IF;

                        mot_extra_cover.extra_field2 :=
                             mot_extra_cover.extra_field2
                           / v_tpcurrent_policy_tenure;
                     END IF;

                     IF lpol.vehicleclass = 'P' THEN
                        /* Private Addon covers */
                        IF NVL (lpol.addonnildepamt, 0) <> 0 THEN
                           v_count := v_count + 1;
                           paddoncover_list.EXTEND ();
                           paddoncover_list (v_count) :=
                                               weo_mot_gen_param ('S3', 'S3');
                        END IF;

                        IF NVL (lpol.addonkeylossamt, 0) <> 0 THEN
                           v_count := v_count + 1;
                           paddoncover_list.EXTEND ();
                           paddoncover_list (v_count) :=
                                             weo_mot_gen_param ('S13', 'S13');
                        END IF;

                        IF NVL (lpolextn.ADDONCONSUMABLESAMT, 0) <> 0 THEN
                           v_count := v_count + 1;
                           paddoncover_list.EXTEND ();
                           paddoncover_list (v_count) :=
                                             weo_mot_gen_param ('S17', 'S17');
                        END IF;

                        IF NVL (lpolextn.addonrtiamt, 0) <> 0 THEN
                           v_count := v_count + 1;
                           paddoncover_list.EXTEND ();
                           paddoncover_list (v_count) :=
                                               weo_mot_gen_param ('S5', 'S5');
                        END IF;

                        IF NVL (lpol.addonengineprotectamt, 0) <> 0 THEN
                           v_count := v_count + 1;
                           paddoncover_list.EXTEND ();
                           paddoncover_list (v_count) :=
                                               weo_mot_gen_param ('S4', 'S4');
                        END IF;

                        IF NVL (lpol.addonperbelongingamt, 0) <> 0 THEN
                           v_count := v_count + 1;
                           paddoncover_list.EXTEND ();
                           paddoncover_list (v_count) :=
                                             weo_mot_gen_param ('S14', 'S14');
                        END IF;

                        IF NVL (lpol.addontyrealloyamt, 0) <> 0 THEN
                           v_count := v_count + 1;
                           paddoncover_list.EXTEND ();
                           paddoncover_list (v_count) :=
                                             weo_mot_gen_param ('S12', 'S12');
                           v_count := v_count + 1;
                           paddoncover_list.EXTEND ();
                           paddoncover_list (v_count) :=
                                             weo_mot_gen_param ('S11', 'S11');
                        END IF;

                        IF NVL (lpolextn.BATTERYCOVERPREMIUM, 0) <> 0 THEN
                           v_count := v_count + 1;
                           paddoncover_list.EXTEND ();
                           paddoncover_list (v_count) :=
                                             weo_mot_gen_param ('S29', 'S29');
                        END IF;

                        /*IF NVL (lpolextn.inconvenienceallowance, 0) <> 0 THEN
                           v_count := v_count + 1;
                           paddoncover_list.EXTEND ();
                           paddoncover_list (v_count) :=
                                               weo_mot_gen_param ('S6', 'S6');
                        END IF;*/

                        IF NVL (lpolextn.addonhighvaluepaamt, 0) <> 0 THEN
                           v_count := v_count + 1;
                           paddoncover_list.EXTEND ();
                           paddoncover_list (v_count) :=
                                               weo_mot_gen_param ('S7', 'S7');
                        END IF;
                     ELSE                        /* Commercial Addon covers */
                        IF NVL (lpol.addonnildepamt, 0) <> 0 THEN
                           v_count := v_count + 1;
                           paddoncover_list.EXTEND ();
                           paddoncover_list (v_count) :=
                                               weo_mot_gen_param ('T3', 'T3');
                        END IF;

                        IF NVL (lpol.addonkeylossamt, 0) <> 0 THEN
                           v_count := v_count + 1;
                           paddoncover_list.EXTEND ();
                           paddoncover_list (v_count) :=
                                             weo_mot_gen_param ('T37', 'T37');
                        END IF;

                        IF NVL (lpolextn.ADDONCONSUMABLESAMT, 0)<>0 THEN
                           v_count := v_count + 1;
                           paddoncover_list.EXTEND ();
                           paddoncover_list (v_count) :=
                                             weo_mot_gen_param ('T34', 'T34');
                        END IF;

                        IF NVL (lpol.addonengineprotectamt, 0) <> 0 THEN
                           v_count := v_count + 1;
                           paddoncover_list.EXTEND ();
                           paddoncover_list (v_count) :=
                                               weo_mot_gen_param ('T4', 'T4');
                        END IF;

                        IF NVL (lpolextn.addonrtiamt, 0) <> 0 THEN
                           v_count := v_count + 1;
                           paddoncover_list.EXTEND ();
                           paddoncover_list (v_count) :=
                                               weo_mot_gen_param ('T5', 'T5');
                        END IF;

                        IF NVL (lpol.addontyrealloyamt, 0) <> 0 THEN
                           v_count := v_count + 1;
                           paddoncover_list.EXTEND ();
                           paddoncover_list (v_count) :=
                                             weo_mot_gen_param ('T12', 'T12');
                           v_count := v_count + 1;
                           paddoncover_list.EXTEND ();
                           paddoncover_list (v_count) :=
                                             weo_mot_gen_param ('T11', 'T11');
                        END IF;

                        /*IF NVL (lpolextn.inconvenienceallowance, 0) <> 0 THEN
                           v_count := v_count + 1;
                           paddoncover_list.EXTEND ();
                           paddoncover_list (v_count) :=
                                             weo_mot_gen_param ('S6A', 'S6A');
                        END IF;*/
                     END IF;

                     BEGIN
                        SELECT VALUE
                        INTO   v_new_eff_date
                        FROM   bjaz_clm_exempt
                        WHERE  control_given = 'NEW_TP_EFF';
                     EXCEPTION
                        WHEN OTHERS THEN
                           v_new_eff_date := TO_DATE(lpol.inspolicycreateddate,'MM/DD/YYYY HH24:MI:SS');
                     END;
dbms_output.put_line('v_new_eff_date= '||v_new_eff_date);
                     IF NVL (lpolextn.isllpaiddriver, 0) >= 1 THEN
                        v_count := v_count + 1;
                        paddoncover_list.EXTEND ();
                        paddoncover_list (v_count) :=
                                             weo_mot_gen_param ('LLO', 'LLO');

                        IF TO_CHAR(trunc(TO_DATE (lpol.inspolicycreateddate, 'MM/DD/YYYY HH24:MI:SS')),'DD-MON-RRRR') <
                                      TO_DATE (v_new_eff_date, 'DD-MON-RRRR') THEN
                           SELECT NVL (no_of_days, 25)
                           INTO   v_rate
                           FROM   bjaz_clm_exempt
                           WHERE  control_given = 'OLD_RATE' AND ROWNUM = 1;
                        ELSE
                           SELECT NVL (no_of_days, 50)
                           INTO   v_rate
                           FROM   bjaz_clm_exempt
                           WHERE  control_given = 'NEW_RATE' AND ROWNUM = 1;
                        END IF;

                        v_llprem := lpolextn.llpaiddrivpremium;
                        mot_extra_cover.no_of_persons_llo :=
                           ROUND (  v_llprem
                                  / TO_NUMBER (v_rate)
                                  / v_tpcurrent_policy_tenure);
                     END IF;

                     IF NVL (lpolextn.isllotheremp, 0) = 1 THEN
                        v_count := v_count + 1;
                        paddoncover_list.EXTEND ();
                        paddoncover_list (v_count) :=
                                             weo_mot_gen_param ('LLE', 'LLE');
                        mot_extra_cover.no_of_employees_lle :=
                                                NVL (lpolextn.llotherempcount, 0);
                     END IF;

                     mot_extra_cover.fibre_glass_value := 0;
                     mot_extra_cover.side_car_value := 0;
                     mot_extra_cover.no_of_trailers := 0;
                     mot_extra_cover.total_trailer_value := 0;
                     mot_extra_cover.covernote_no := lpol.transactionid;
                     mot_extra_cover.covernote_date := NULL;
                     mot_extra_cover.extra_field3 :=
                          TO_CHAR(to_date(lpol.inspolicyeffectivedate,'MM/DD/YYYY HH24:MI:SS'),'DD-MON-YYYY');
                     DBMS_OUTPUT.put_line
                                 ('Step 9 >> Before calling calculate premium');

                     IF p_error_code = 0 THEN
                        p_weo_mot_policy_in.term_start_date :=
                            TO_CHAR(TO_DATE(lpol.inspolicyeffectivedate,'MM/DD/YYYY'),'DD-MON-YYYY');
DBMS_OUTPUT.PUT_LINE('1584 p_weo_mot_policy_in.term_start_date= '||p_weo_mot_policy_in.term_start_date);
                        customer.BJAZ_LEXUS_WEBSERVICE.calculate_motor_premium
                                                       (pidvvalue, 'LEXUS',
                                                        p_weo_mot_policy_in,
                                                        accessories_list,
                                                        paddoncover_list,
                                                        mot_extra_cover,
                                                        phiddenvar,
                                                        p_quest_list,
                                                        premium_details_out,
                                                        premium_summery_list,
                                                        v_stax_dtls, p_error,
                                                        p_error_code,
                                                        v_stax_dtls_basic_tp,
                                                        v_stax_dtls_other_tp);

                        p_weo_mot_policy_in.term_start_date :=
                           TO_CHAR(TRUNC(TO_DATE(lpol.inspolicyeffectivedate,'MM/DD/YYYY HH24:MI:SS')),'DD-MON-YYYY');
                        mot_extra_cover.extra_field1 :=
                                                 lpolextn.previnsurcompanyadd;
                        mot_extra_cover.extra_field3 := gv_comm_disc_amt;
                     END IF;

                     DBMS_OUTPUT.put_line
                            (   'Step 9 >> premium_details_out.final_premium '
                             || premium_details_out.final_premium);
DBMS_OUTPUT.put_line
                            (   'Step 9 >> lpolextn.grosspremium '
                             || lpolextn.grosspremium);
                             DBMS_OUTPUT.put_line
                            (   'Step 9.1 >> p_error.COUNT '
                             || p_error.COUNT);
                  EXCEPTION
                     WHEN OTHERS THEN
                        COMMIT;

                        IF p_error.COUNT () > 0 THEN
                           FOR i IN 1 .. p_error.COUNT () LOOP
                              error_comments :=
                                    'ERROR WHILE COMPUTING PREMIUM. '
                                 || p_error (i).err_text; --changes for 57420986 - Proper Error message need to provide on interface/report
                              p_error_code := 1;
                              save_error_code (lpol.transactionid,
                                               p_error_code, error_comments);
                              RETURN;
                           END LOOP;
                        END IF;
                  END;

                  BEGIN
                     SELECT no_of_days
                     INTO   v_short_limit
                     FROM   bjaz_clm_exempt
                     WHERE  control_given = 'SHORTLIMIT_' || 'LEXUS_SYS';
                  EXCEPTION
                     WHEN OTHERS THEN
                        v_short_limit := 5;
                  END;

                  IF ABS (  NVL (premium_details_out.final_premium, 0)
                          - NVL (lpolextn.grosspremium, 0)) > v_short_limit THEN
                     error_comments :=
                           'LEXUS PREMIUM '
                        || lpolextn.grosspremium
                        || ' IS LESS/GREATER THAN BJAZ PREMIUM AMOUNT '
                        || premium_details_out.final_premium
                        || '.';
                     p_error_code := 1;
                     save_error_code (lpol.transactionid, p_error_code,
                                      error_comments);
                     RETURN;
                  END IF;

                  IF p_error.COUNT () > 0 THEN
                     FOR i IN 1 .. p_error.COUNT () LOOP
                        UPDATE bjaz_LEXUS_ws_data
                        SET error_desc =
                                   error_desc || ' + ' || p_error (i).err_text
                        WHERE  transactionid = lpol.transactionid;
            COMMIT;
                     END LOOP;

                     RETURN;
                  END IF;

                  DBMS_OUTPUT.put_line
                                   ('Step 9 >> End of the premium calculation');
                  /*End:Calculate Premium*/
                  DBMS_OUTPUT.put_line ('Step 10 >> Starts Receipt Generation');

                  /*REATE RECEIPT DETAILS STARTS*/
                  BEGIN
                     IF p_error_code = 0 THEN
                        IF UPPER (TRIM (NVL (lpol.vehicleclass, NULL))) = 'P' THEN
                           IF lpol.inspolicytype = 'N'
                              AND trunc(to_date(lpol.VEHICLEINVOICEDATE, 'MM/DD/YYYY HH24:MI:SS')) >=
                                                          v_tp_effective_date THEN
                              prodcode := '1825';                   --'1801';
                           ELSE
                               IF lpolextn.isstandaloneod = 1
                              THEN
                                 prodcode := '1870';
                              ELSIF nvl(lpolextn.netodpremium,0) = 1
                              THEN
                                 prodcode := '1805';
                              ELSE
                                 prodcode := '1801';
                              END IF;
                           END IF;
                        ELSIF UPPER (TRIM (NVL (lpol.vehicleclass, NULL))) IN
                                                ('C1', 'C2', 'G1', 'G2', 'C')
                              AND lpol.seatingcapacity <= 7 THEN
                           prodcode := '1803';
                        ELSIF UPPER (TRIM (NVL (lpol.vehicleclass, NULL))) IN
                                                                        ('A') THEN
                           prodcode := '1811';
                        ELSIF UPPER (TRIM (NVL (lpol.vehicleclass, NULL))) IN
                                                ('C1', 'C2', 'G1', 'G2', 'C')
                              AND lpol.seatingcapacity >= 8 THEN
                           prodcode := '1812';
                        ELSE
                           COMMIT;
                           p_error_code := 1;
                           error_comments := 'VEHICLE TYPE IS NOT MENTIONED';
                           save_error_code (lpol.transactionid, p_error_code,
                                            error_comments);
                           RETURN;
                        END IF;

                        DBMS_OUTPUT.put_line (   'Step 10 >> prodcode '
                                              || prodcode);

                        <<block_4>>
                        BEGIN
                           SELECT x1.bjaz_receipt
                             INTO v_receipt_no
                             FROM bjaz_mibl_ws_receipt_tb x1,
                                  bjaz_receipts x2
                            WHERE     X1.BJAZ_RECEIPT = X2.RECEIPT_NO
                                  AND polno = lpol.TRANSACTIONID   --LPOL.PONO
                                  AND tieup_name = 'LEXUS'
                                  AND x2.receipt_req_id IS NULL
                                  AND x1.top_indicator = 'Y';

                           SELECT SCRUTINY_NO
                             INTO v_scrutiny_no
                             FROM BJAZ_LEXUS_WS_DATA
                            WHERE     TRANSACTIONID = lpol.TRANSACTIONID
                                  AND bjazpolicyno IS NULL;

                           DBMS_OUTPUT.put_line (
                              'MMM LEXUS v_receipt_no>' || v_receipt_no);
                           DBMS_OUTPUT.put_line (
                              'MMM LEXUS v_SCRUTINY_NO>' || v_SCRUTINY_NO);
                        EXCEPTION
                           WHEN OTHERS
                           THEN
                              DBMS_OUTPUT.put_line (
                                 'EXCEPTION IN GETTIMG SCR AND RCPT>');
                              v_receipt_no := NULL;
                              v_scrutiny_no := NULL;
                        END block_4;

                        BEGIN
                           IF v_receipt_no IS NULL AND v_scrutiny_no IS NULL
                           THEN
                              UPDATE BJAZ_LEXUS_WS_DATA
                                 SET scrutiny_no = NULL
                               WHERE TRANSACTIONID = lpol.TRANSACTIONID;

                              COMMIT;
                           END IF;
                        EXCEPTION
                           WHEN OTHERS
                           THEN
                              NULL;
                        END;

              BEGIN
                           SELECT imd_code
                           INTO   v_nf_imd_code
                           FROM   bjaz_packpol_agent_validations
                           WHERE  user_level = 'LEXUS_NF_IMD'
               AND    top_indicator = 'Y';
                        EXCEPTION
                           WHEN OTHERS THEN
                              v_nf_imd_code := NULL;
                        END;
dbms_output.put_line('1772 v_nf_imd_code>>>>>>>>= '||v_nf_imd_code);

                 IF   NVL (bjaz_utils.get_param_value ('NTUNFCONF', lpol.financercode,
                                                               0,
                                                               TRUNC (SYSDATE)),
                                   0) = 0 THEN


                        DBMS_OUTPUT.put_line (   'Step 10 >> v_receipt_no '|| v_receipt_no);
                        reciept_mst.partner_id := bjaz_ski_part.bjaz_part_id;
                        reciept_mst.ski_receipt_no := lpol.transactionid;
                        reciept_mst.receipt_no := v_receipt_no;
                        reciept_mst.imd_code := gv_LEXUS_imd_code;
                        reciept_mst.comments := NULL;
                        reciept_mst.partner_type := partner_type;
                        reciept_mst.receipt_amt :=
                                               NVL (v_total_chequeamount, '0');
                        reciept_mst.proposal_form_nos := NULL;
                        reciept_mst.proposal_form_amt := NULL;
                        reciept_mst.ski_agent_code := gv_LEXUS_imd_code;
                        reciept_mst.type_of_receipt := 'CUSTFLOAT';
                        reciept_mst.receipt_status := 'P';

                        IF INSTR (lpol.transactionid, 'WBA') <> 0 THEN
                           v_instr_type := 'CC';
                        ELSE
                           v_instr_type := 'CH';
                        END IF;

                        DBMS_OUTPUT.put_line (   '1797 Step 10 >> v_receipt_no 1'
                                              || v_receipt_no);

                        <<block_3>>
                        BEGIN
                           SELECT bank_name
                           INTO   v_bankname
                           FROM   bjaz_mibl_bank_dtls
                           WHERE  bank_code = lpolextn.reconciledchequebank
                                  AND top_indicator = 'Y' AND tieup = 'LEXUS';
                        EXCEPTION
                           WHEN OTHERS THEN
                              p_error_code := 1;
                              error_comments := 'BANK DETAILS ARE NOT FOUND ';
                              save_error_code (lpol.transactionid,
                                               p_error_code, error_comments);
                              COMMIT;
                              RETURN;
                        END block_3;

           --  IF lpolextn.reconciledchequeissuedby IN ('D','F','O','Z','C','L') THEN  --For call 50320783 by Nitin  --Commented for call 50736455 by Nitin
                   v_branchname_withPolno:= lpolextn.reconciledchequebranch|| p_LEXUSpono;
                  -- END IF;

                      IF UPPER(lpolextn.proposerpaymentmode) IN ('O','L'/*,'C'*/,'Z') THEN

                v_instr_type := 'OL';

                ELSIF UPPER(lpolextn.proposerpaymentmode) IN ('C','I') THEN

                v_instr_type := 'CH';

              END IF;




                        DBMS_OUTPUT.put_line (   'Step 10 >> v_bankname '
                                              || v_bankname);
                        inst_list.EXTEND ();
                        inst_list (1) :=
                           bjaz_ski_instument
                                    (bjaz_ski_part.bjaz_part_id, v_instr_type,
                                     NVL (v_total_chequeamount, 0), 1,
                                     gv_LEXUS_debit_bank_acc,
                                     NVL (v_bankname, NULL),
                                     NVL (v_branchname_withPolno, lpolextn.reconciledchequebranch), --For call 50320783 by Nitin
                                     CASE
                                        WHEN LENGTH (v_chequeno) > 6 THEN v_chequeno
                                        ELSE LPAD (v_chequeno, 6, 0)
                                     END,
                                     TO_CHAR(TRUNC(TO_DATE(lpolextn.reconciledchequedate,'MM/DD/YYYY HH24:MI:SS')),'DD-MON-YYYY'),
                                     1, NULL);
                        prod_list.EXTEND ();
                        prod_list (1) :=
                           bjaz_ski_product
                                       (prodcode,
                                        TO_CHAR(TRUNC(TO_DATE(lpol.inspolicyeffectivedate,'MM/DD/YYYY HH24:MI:SS')),'DD-MON-YYYY'),
                                        TO_CHAR(TRUNC(TO_DATE(lpol.inspolicyexpirydate,'MM/DD/YYYY HH24:MI:SS')),'DD-MON-YYYY'),
                                        NULL, lpol.vehicleidv, insured_name,
                                        NVL (lpol.address1, NULL),
                                        NVL (v_cityname, NULL), NULL,
                                        NVL (v_bankname, NULL),
                                        lpol.transactionid, NULL);
                        DBMS_OUTPUT.put_line
                                           (   'Step 10 >> v_cnt_covernote>> '
                                            || v_cnt_covernote);

         END IF;            --ADDED BY RAVI AKKA FOR AGENTFLOAT


                        IF v_cnt_covernote > 0 THEN
                           FOR cur IN
                              (SELECT a.transactionid, b.reconciledchequeamount,
                                      b.grosspremium
                               FROM   bjaz_LEXUS_ws_data a join bjaz_lexus_ws_data_extn b
                               on a.transactionid=b.transactionid
                               WHERE  b.reconciledchequeno = v_chequeno
                                      AND b.reconciledchequebank =
                                                    lpolextn.reconciledchequebank
                                      AND b.reconciledchequedate =
                                                    lpolextn.reconciledchequedate
                                      AND TRUNC (a.last_uploaddate) =
                                            (SELECT TRUNC (last_uploaddate)
                                             FROM   bjaz_LEXUS_ws_data
                                             WHERE  transactionid =
                                                           lpol.transactionid)
                                      AND a.bjaz_receipt IS NULL
                                      AND a.transactionid = lpol.transactionid) LOOP
                              v_cheq_amt := cur.reconciledchequeamount;
                              v_bjaz_premium := cur.grosspremium;
                              DBMS_OUTPUT.put_line
                                 ('Step 10 >> before calling internal scrutiny>>');
                              bjaz_nissan_utils.get_internal_scrutiny
                                                          (LEXUS_user_name,
                                                           cur.transactionid,
                                                           v_receipt_no,
                                                           v_scrutiny_no,
                                                           p_weo_mot_policy_in.product_4digit_code);

                  IF nvl(v_scrutiny_no,0)=0 and BJAZ_HSCI_UTILS.gv_scr_fail_reason is not null THEN       --For call 50738259 by nitin shrikant
                      error_comments :=
                                 'ERROR WHILE GENERATING SCRUTINY ->' || BJAZ_HSCI_UTILS.gv_scr_fail_reason;
                           p_error_code := 1;
                           save_error_code (lpol.transactionid, p_error_code,
                                            error_comments);
                           error_comments := NULL;
                           RETURN;

                      END IF;

                              p_scr_dtls_list.EXTEND ();
                              p_scr_dtls_list (p_scr_dtls_list.COUNT) :=
                                 weo_rec_strings40 (NULL, v_scrutiny_no,
                                                    NULL,
                                                    v_total_chequeamount,
                                                    v_bjaz_premium,
                                                    v_cheq_amt, NULL, NULL,
                                                    NULL, NULL, NULL, NULL,
                                                    NULL, NULL, NULL, NULL,
                                                    NULL, NULL, NULL, NULL,
                                                    NULL, NULL, NULL, NULL,
                                                    NULL, NULL, NULL, NULL,
                                                    NULL, NULL, NULL, NULL,
                                                    NULL, NULL, NULL, NULL,
                                                    NULL, NULL, NULL, NULL);
                           END LOOP;
                        END IF;

                        DBMS_OUTPUT.put_line (   'Step 10 >> v_scrutiny_no>> '
                                              || v_scrutiny_no);

                        BEGIN
                           SELECT scrutiny_no
                           INTO   v_scrutiny_no
                           FROM   bjaz_LEXUS_ws_data
                           WHERE  transactionid = lpol.transactionid;
                        EXCEPTION
                           WHEN OTHERS THEN
                              error_comments :=
                                              'SCRUTINY NUMBER IS NOT FOUND ';
                              p_error_code := 1;
                              save_error_code (lpol.transactionid,
                                               p_error_code, error_comments);
                              RETURN;
                        END;

                        IF NVL (v_scrutiny_no, 0) = 0 THEN
                           error_comments := 'SCRUTINY NUMBER NOT FOUND ';--changes for 57420986 - Proper Error message need to provide on interface/report
                           p_error_code := 1;
                           save_error_code (lpol.transactionid, p_error_code,
                                            error_comments);
                           RETURN;
                        END IF;

                        DBMS_OUTPUT.put_line
                                            (   'Step 10 >> v_scrutiny_no>> 1'
                                             || v_scrutiny_no
                                             || 'p_error_code '
                                             || p_error_code
                                             || 'v_receipt_no '
                                             || v_receipt_no);

                      IF NVL
                                  (bjaz_utils.get_param_value ('NTUNFCONF', lpol.financercode,
                                                               0,
                                                               TRUNC (SYSDATE)),
                                   0) = 1 THEN
                           l_cust_float :=
                              bjaz_pk0_general.get_npda_loader_receipt_tag
                                       ('NAF', LEXUS_user_name,
                                        v_nf_imd_code,
                                        lpol.bjaz_loc_code,
                                        -- lpol.bjaz_loc_code,
                                        v_scrutiny_no,
                                        '', NVL (v_bjaz_premium, 0),
                                        p_error_code,
                                        TRUNC(TO_DATE (lpol.inspolicyeffectivedate,'MM/DD/YYYY HH24:MI:SS')));
                           DBMS_OUTPUT.put_line
                                      ('Step 10 >>  l_cust_float.COUNT>> '
                                       || l_cust_float.COUNT);

                           IF l_cust_float.COUNT = 0 THEN
                              p_error_code := 1;
                              error_comments :=
                                 'ERROR WHILE FETCHING THE BALANCE. PLEASE CHECK THE AGENT FLOAT BALANCE.';
                              save_error_code (lpol.transactionid,
                                               p_error_code, error_comments);
                              RETURN;
                           END IF;
                        ELSE



                        IF p_error_code = 0 THEN
                           BEGIN
                              IF NVL (v_receipt_no, '0') = '0' THEN
                                 DBMS_OUTPUT.put_line
                                    ('Step 10 >> Before calling issue receipt');
                                 customer.BJAZ_LEXUS_WEBSERVICE.issue_reciept
                                                         ('LEXUS',
                                                          LEXUS_user_name,
                                                          'POLICY',
                                                          p_scr_dtls_list,
                                                          LEXUS_password,
                                                          lpol.bjaz_loc_code,
                                                          reciept_mst,
                                                          inst_list,
                                                          prod_list, p_error,
                                                          p_error_code);
                              ELSE
                                 p_receipt_dtls.stringval1 :=
                                                   reciept_mst.ski_receipt_no;
                                 p_receipt_dtls.stringval2 :=
                                                       reciept_mst.receipt_no;
                                 p_receipt_dtls.stringval3 :=
                                                reciept_mst.proposal_form_nos;
                                 p_receipt_dtls.stringval4 :=
                                                reciept_mst.proposal_form_amt;
                                 p_receipt_dtls.stringval5 :=
                                                   reciept_mst.ski_agent_code;
                                 p_receipt_dtls.stringval6 := 'SUCCESS';
                                 v_rcpt_rslt :=
                                    bjaz_dfs_utils.ins_receipt_dtls_tb
                                                             (p_receipt_dtls,
                                                              'LEXUS_P',
                                                              'POLICY');
                              END IF;

                              DBMS_OUTPUT.put_line
                                      (   'Step 10 >> After receipt creation '
                                       || reciept_mst.ski_receipt_no);
                              DBMS_OUTPUT.put_line
                                                (   'Step 10 >> p_error_code '
                                                 || p_error_code);

                              IF p_error_code = 0 THEN
                                 DBMS_OUTPUT.put_line
                                              (   'Step 10 >> p_error_code 1'
                                               || p_error_code);

                                 SELECT COUNT (*)
                                 INTO   v_cnt
                                 FROM   bjaz_64vb_coll_stage
                                 WHERE  receipt_no = reciept_mst.receipt_no
                                        AND cheque_status = 'C'
                                        AND top_ind = 'Y' AND ROWNUM < 2;

                                 DBMS_OUTPUT.put_line
                                               (   'Step 10 >> p_error_code 2'
                                                || p_error_code);

                                 IF v_cnt <> 0 OR  v_instr_type = 'OL' THEN
                                    UPDATE bjaz_receipts
                                    SET agent_id = gv_LEXUS_imd_code,
                                        ri_effective_date =
                                           TRUNC(TO_DATE(lpolextn.reconciledchequedate,'MM/DD/YYYY HH24:MI:SS'))
                                    WHERE  receipt_no = reciept_mst.receipt_no
                                           AND (agent_id IS NULL
                                                OR agent_id =
                                                            gv_LEXUS_imd_code
                                               );
                                 ELSE
                                    DBMS_OUTPUT.put_line
                                              (   'Step 10 >> p_error_code 3'
                                               || p_error_code);

                                    UPDATE bjaz_receipts
                                    SET agent_id = gv_LEXUS_imd_code,
                                        ri_effective_date =
                                           TRUNC(TO_DATE(lpolextn.reconciledchequedate,'MM/DD/YYYY HH24:MI:SS')),
                                        cheque_status = 'S'
                                    WHERE  receipt_no = reciept_mst.receipt_no
                                           AND (agent_id IS NULL
                                                OR agent_id =
                                                            gv_LEXUS_imd_code
                                               );
                                 END IF;
                              ELSE
                                 COMMIT;
                                 DBMS_OUTPUT.put_line
                                              (   'Step 10 >> p_error_code 4'
                                               || p_error_code);
                                 bjaz_marsh_utils.clear_failed_policy
                                                          (lpol.transactionid,
                                                           'LEXUS',
                                                           v_scrutiny_no);

                                 IF p_error.COUNT () > 0 THEN
                                    FOR i IN 1 .. p_error.COUNT () LOOP
                                       error_comments :=
                                             'ERROR IN CREATING RECEIPT. '
                                          || p_error (i).err_text;
                                       p_error_code := 5;
                                       save_error_code (lpol.transactionid,
                                                        p_error_code,
                                                        error_comments);
                                       RETURN;
                                    END LOOP;
                                 END IF;
                              END IF;
                           EXCEPTION
                              WHEN OTHERS THEN
                                 COMMIT;
                                 bjaz_marsh_utils.clear_failed_policy
                                                         (lpol.transactionid,
                                                          'LEXUS',
                                                          v_scrutiny_no);

                                 IF p_error.COUNT () > 0 THEN
                                    FOR i IN 1 .. p_error.COUNT () LOOP
                                       error_comments :=
                                             'ERROR INSIDE THE CREATING RECEIPT. '
                                          || p_error (i).err_text;
                                       p_error_code := 5;
                                       save_error_code (lpol.transactionid,
                                                        p_error_code,
                                                        error_comments);
                                       RETURN;
                                    END LOOP;
                                 END IF;
                           END;
                        END IF;
                     END IF;

             END IF;

                  END;

                  DBMS_OUTPUT.put_line
                                     ('Step 10 >> End of the receipt creation');
                  DBMS_OUTPUT.put_line ('Step 11 >> Start Policy Issuance');

                  /*End:-Create receipt*/

                  /*START:Issue Motor Policy*/
                  IF p_error_code = 0 THEN
                     p_weo_mot_policy_in :=
                        weo_mot_plan_details
                                  (p_weo_mot_policy_in.contract_id,
                                   p_weo_mot_policy_in.pol_type,
                                   p_weo_mot_policy_in.product_4digit_code,
                                   p_weo_mot_policy_in.dept_code,
                                   p_weo_mot_policy_in.branch_code,
                                   TO_CHAR (TRUNC(TO_DATE(lpol.inspolicyeffectivedate,'MM/DD/YYYY HH24:MI:SS')),'DD-MON-YYYY'),
                                   TO_CHAR (TRUNC(TO_DATE(lpol.inspolicyexpirydate,'MM/DD/YYYY HH24:MI:SS')),'DD-MON-YYYY'),
                                   p_weo_mot_policy_in.tp_fin_type,
                                   p_weo_mot_policy_in.hypo,
                                   p_weo_mot_policy_in.vehicle_type_code,
                                   p_weo_mot_policy_in.vehicle_type,
                                   p_weo_mot_policy_in.misc_veh_type,
                                   p_weo_mot_policy_in.vehicle_make_code,
                                   p_weo_mot_policy_in.vehicle_make,
                                   p_weo_mot_policy_in.vehicle_model_code,
                                   p_weo_mot_policy_in.vehicle_model,
                                   p_weo_mot_policy_in.vehicle_subtype_code,
                                   p_weo_mot_policy_in.vehicle_subtype,
                                   p_weo_mot_policy_in.fuel,
                                   p_weo_mot_policy_in.ZONE,
                                   p_weo_mot_policy_in.engine_no,
                                   p_weo_mot_policy_in.chassis_no,
                                   p_weo_mot_policy_in.registration_no,
                                   p_weo_mot_policy_in.registration_date,
                                   p_weo_mot_policy_in.registration_location,
                                   p_weo_mot_policy_in.regi_loc_other,
                                   p_weo_mot_policy_in.carrying_capacity,
                                   p_weo_mot_policy_in.cubic_capacity,
                                   p_weo_mot_policy_in.year_manf,
                                   p_weo_mot_policy_in.color,
                                   p_weo_mot_policy_in.vehicle_idv,
                                   p_weo_mot_policy_in.ncb,
                                   p_weo_mot_policy_in.add_loading,
                                   p_weo_mot_policy_in.add_loading_on,
                                   p_weo_mot_policy_in.sp_disc_rate,
                                   p_weo_mot_policy_in.elec_acc_total,
                                   p_weo_mot_policy_in.non_elec_acc_total,
                                   p_weo_mot_policy_in.prv_policy_ref,
                                   p_weo_mot_policy_in.prv_expiry_date,
                                   p_weo_mot_policy_in.prv_ins_company,
                                   p_weo_mot_policy_in.prv_ncb,
                                   p_weo_mot_policy_in.prv_claim_status,
                                   p_weo_mot_policy_in.auto_membership,
                                   p_weo_mot_policy_in.partner_type);
                  END IF;

                  DBMS_OUTPUT.put_line
                                      ('Step 11 >> Start Policy Issuance ==>1');

                  BEGIN



             IF NVL
                                  (bjaz_utils.get_param_value ('NTUNFCONF', lpol.financercode,
                                                               0,
                                                               TRUNC (SYSDATE)),
                                   0) = 1 THEN
                        p_rcpt_bal :=
                           bjaz_acc_utils.get_float_balance
                                                     (  v_nf_imd_code,
                                                      reciept_mst.receipt_no,
                                                      1, v_scrutiny_no
                           );
                     ELSE



                     <<block_12>>
                     BEGIN
                        ppremiumpayerid :=
                           bjaz_marsh_utils.get_rcpt_partner
                                                         (lpol.transactionid,
                                                          'LEXUS');
                        DBMS_OUTPUT.put_line
                                     ('Step 11 >> Start Policy Issuance ==>2');
                        p_rcpt_bal :=
                           bjaz_acc_utils.get_pca_balance
                                                     (ppremiumpayerid,
                                                      reciept_mst.receipt_no,
                                                      1, v_scrutiny_no);
                        DBMS_OUTPUT.put_line
                                     ('Step 11 >> Start Policy Issuance ==>3');
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_rcpt_bal := 0;
                     END block_12;

                  END IF;               --ADDED BY RAVI AKKA FOR AGENTFLOAT


                     BEGIN
                        v_rcpt_remarks :=
                              'p_user_location_code='
                           || loccode
                           || '~p_user_acode='
                           || gv_LEXUS_imd_code
                           || '~p_user_name='
                           || LEXUS_user_name
                           || '~p_type_of_float='
                           || ''
                           || '~p_loc_code='
                           || loccode
                           || '~p_imd_code='
                           || gv_LEXUS_imd_code
                           || '~p_part_code='
                           || ppart_id
                           || '~p_scrutiny_no='
                           || v_scrutiny_no
                           || '~p_tag_status='
                           || ''
                           || '~p_premium_amount='
                           || premium_details_out.total_premium
                           || '~p_product_code='
                           || p_weo_mot_policy_in.product_4digit_code
                           || '~p_module_id='
                           || 'LEXUS_UPLOAD_POLICY';
                     EXCEPTION
                        WHEN OTHERS THEN
                           v_rcpt_remarks := '';
                     END;


                   IF NVL
                                  (bjaz_utils.get_param_value ('NTUNFCONF', lpol.financercode,
                                                               0,
                                                               TRUNC (SYSDATE)),
                                   0) = 1 THEN
                        FOR i IN 1 .. l_cust_float.COUNT LOOP
                           DBMS_OUTPUT.put_line
                              ('Step 10 >>   l_cust_float (i).receipt_no>> '
                               || l_cust_float (i).receipt_no);
                           p_rcpt_list.EXTEND;
                           p_rcpt_list (p_rcpt_list.COUNT) :=
                              weo_tyac_pay_row
                                              (l_cust_float (i).posting_amt,
                                               'FLOAT',
                                               l_cust_float (i).posting_amt,

                                               --1,
                                               l_cust_float (i).collection_no,
                                               l_cust_float (i).receipt_no,

                                               --new tagging structure
                                               l_cust_float (i).from_scrutiny,
                                               l_cust_float (i).to_scrutiny,
                                               l_cust_float (i).tag_status,
                                               NULL, NULL, NULL, NULL, NULL,
                                               NULL, NULL, NULL,
                                               v_rcpt_remarks, NULL, NULL,
                                               NULL, NULL, NULL);
                        END LOOP;
                     ELSE


                     DBMS_OUTPUT.put_line
                                      ('Step 11 >> Start Policy Issuance ==>4');
                     p_rcpt_list.EXTEND ();
                     p_rcpt_list (1) :=
                        weo_tyac_pay_row (NVL (lpolextn.reconciledchequeamount, 0),
                                          2, NVL (p_rcpt_bal, 0),
                                          v_scrutiny_no,
                                          reciept_mst.receipt_no,
                                          v_scrutiny_no, '', 'BLOCK', NULL,
                                          NULL, NULL, NULL, NULL, NULL, NULL,
                                          NULL, v_rcpt_remarks, NULL, NULL,
                                          NULL, NULL, NULL);
                        END IF;

                     p_cust_details.part_temp_id := bjaz_ski_part.bjaz_part_id;

                     IF lpol.proposertype = 'C' THEN
                        p_cust_details.first_name :=
                                                 NVL (lpol.companyname, NULL);
                     ELSE
                        p_cust_details.first_name :=
                                                   NVL (lpol.firstname, NULL);
                        p_cust_details.middle_name :=
                                                  NVL (lpol.middlename, NULL);
                        p_cust_details.surname := NVL (lpol.lastname, NULL);
                     END IF;

                     DBMS_OUTPUT.put_line
                                  (   'Step 11 >> Start Policy Issuance ==>5 '
                                   || p_cust_details.part_temp_id);
                     p_cust_details.add_line1 := NVL (address1, NULL);
                     p_cust_details.add_line2 := NVL (address2, NULL);
                     p_cust_details.add_line3 := NVL (v_cityname, NULL);
                     p_cust_details.add_line5 := NVL (v_statename, NULL);
                     p_cust_details.pincode := NVL (lpol.pincode, 0);
                     p_cust_details.email := NULL;
                     p_cust_details.telephone1 := NULL;
                     p_cust_details.telephone2 := NULL;
                     p_cust_details.mobile := NULL;
                     p_cust_details.delivary_option := NULL;
                     p_cust_details.pol_add_line1 := NULL;
                     p_cust_details.pol_add_line2 := NULL;
                     p_cust_details.pol_add_line3 := NULL;
                     p_cust_details.pol_add_line5 := NULL;
                     p_cust_details.pol_pincode := NULL;
                     p_cust_details.PASSWORD := NULL;
                     p_cust_details.cp_type := NULL;
                     p_cust_details.profession := NULL;
                     p_cust_details.date_of_birth := NULL;
                     p_cust_details.available_time := NULL;
                     p_cust_details.institution_name :=
                                                  NVL (lpol.companyname, NULL);
                     p_cust_details.existing_yn := 'Y';
                     p_cust_details.logged_in := NULL;
                     p_cust_details.mobile_alerts := NULL;
                     p_cust_details.email_alerts := NULL;
                     p_cust_details.title := NVL (lpol.salutation, NULL);
                     p_cust_details.part_id := bjaz_ski_part.bjaz_part_id;
                     p_cust_details.status1 := NULL;
                     p_cust_details.status2 := NULL;
                     p_cust_details.status3 := NULL;
                     ppremiumpayerid :=
                        bjaz_marsh_utils.get_rcpt_partner (lpol.transactionid,
                                                           'LEXUS');

                     IF ppremiumpayerid = 0 THEN
                        ppremiumpayerid := bjaz_ski_part.bjaz_part_id;
                     END IF;

                     paymentmode := 'Customer Float';
                     locationid := lpol.bjaz_loc_code;
                     potherdetails.imdcode := gv_LEXUS_imd_code;
                     potherdetails.covernote_no := lpol.transactionid;
                     p_instrument_type := NULL;
                     DBMS_OUTPUT.put_line
                                     (   'Step 11 >> Start BJAZ_PREMIUM ==>6 '
                                      || premium_details_out.final_premium);
                     DBMS_OUTPUT.put_line
                                   (   'Step 11 >> Start LEXUS PREMIUM ==>6 '
                                    || lpolextn.grosspremium);

                     <<block_10>>
                     BEGIN
                        IF ABS (  NVL (premium_details_out.final_premium, 0)
                                - NVL (lpolextn.grosspremium, 0)) > v_short_limit THEN
                           error_comments :=
                                 'LEXUS PREMIUM '
                              || lpolextn.grosspremium
                              || ' IS LESS THAN PREMIUM AMOUNT '
                              || premium_details_out.final_premium
                              || '.';
                           p_error_code := 1;
                           save_error_code (lpol.transactionid, p_error_code,
                                            error_comments);
                           error_comments := NULL;
                           RETURN;
                        END IF;

                        DBMS_OUTPUT.put_line
                                      ('Step 11 >> Start Policy Issuance ==>7');

/*added by abhishek for call 54724175*/

               /*        IF p_weo_mot_policy_in.chassis_no IS NOT NULL THEN
                           BEGIN
                              bjaz_hsci_utils.validate_chassis_num
                                             (p_weo_mot_policy_in.chassis_no,
                                              error_comments);
EXCEPTION
                              WHEN OTHERS THEN
                                 error_comments := '';
                           END;           */

 error_comments := '';
 IF p_weo_mot_policy_in.chassis_no IS NOT NULL
      THEN
        BEGIN
         v_chassis_no := TRIM (p_weo_mot_policy_in.chassis_no);
         IF bjaz_utils.allow_special_character (v_chassis_no) = 1
         THEN
            error_comments := 'Chassis number is not valid. Please enter valid Chassis no ';
         END IF;
         IF LENGTH (v_chassis_no) > 22
         THEN
            error_comments :=
                  error_comments
               || 'Length of chassis number should not be greater than 22 digits. ';
         END IF;
         IF error_comments IS NOT NULL
         THEN
            error_comments := error_comments || 'Chassis no: ' || v_chassis_no || '.';
         END IF;
    -- END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         error_comments := '';
END;

/*added by abhishek for call 54724175*/
DBMS_OUTPUT.put_line('2435 Step 11 >> error_comments= '||error_comments);

                           DBMS_OUTPUT.put_line
                                      ('Step 11 >> Start Policy Issuance ==>8');

                           IF error_comments IS NOT NULL THEN
                              p_error_code := 1;
                              COMMIT;
                              error_comments :=
                                    'INVALID CHASSIS NO.'
                                 || p_weo_mot_policy_in.chassis_no;
                              save_error_code (lpol.transactionid,
                                               p_error_code, error_comments);
                              error_comments := NULL;
                              RETURN;
                              else
                                p_error_code := 0;
                           END IF;
                        END IF;
DBMS_OUTPUT.put_line('2473 Step 11 >> p_error_code= '||p_error_code);
                        DBMS_OUTPUT.put_line
                                      ('Step 11 >> Start Policy Issuance ==>9');

                        IF (  NVL (premium_details_out.final_premium, 0)
                            - NVL (v_total_chequeamount, 0)
                           ) > v_short_limit THEN
                           error_comments :=
                                 'RECEIPT AMOUNT IS LESS THAN PREMIUM AMOUNT.'
                              || 'RCPT AMT='
                              || premium_details_out.final_premium
                              || '#PREMIUM='
                              || lpolextn.reconciledchequeamount
                              || '#v_total_chequeamount='
                              || v_total_chequeamount;
                           p_error_code := 1;
                           save_error_code (lpol.transactionid, p_error_code,
                                            error_comments);
                           RETURN;
                        END IF;
                     END block_10;
DBMS_OUTPUT.put_line('2473 Step 11 >> p_error_code= '||p_error_code);
                     DBMS_OUTPUT.put_line
                                     ('Step 11 >> Start Policy Issuance ==>10');
DBMS_OUTPUT.put_line
                                     ('Step 11 >> Start Policy Issuance ==>10 p_weo_mot_policy_in.term_start_date
                                     = '||p_weo_mot_policy_in.term_start_date);
                     <<block_11>>
                     BEGIN
                        IF TO_CHAR(TO_DATE(
                              p_weo_mot_policy_in.term_start_date,'DD-MON-YYYY'),'RRRR') = '1899' THEN
                           COMMIT;
                           error_comments :=
                                 ':->TERM START DATE IS WRONG. TERM START DATE ['
                              || p_weo_mot_policy_in.term_start_date
                              || ']';
                           p_error_code := 1;
                           save_error_code (lpol.transactionid, p_error_code,
                                            error_comments);
                           error_comments := NULL;
                           RETURN;
                        END IF;
                     EXCEPTION
                        WHEN OTHERS THEN
                           COMMIT;
                           error_comments :=
                                 'TERM START DATE IS WRONG. TERM START DATE ['
                              || p_weo_mot_policy_in.term_start_date
                              || ']';
                           p_error_code := 1;
                           save_error_code (lpol.transactionid, p_error_code,
                                            error_comments);
                           RETURN;
                     END block_11;

                 IF NVL
                                  (bjaz_utils.get_param_value ('NTUNFCONF', lpol.financercode,
                                                               0,
                                                               TRUNC (SYSDATE)),
                                   0) = 1 THEN
                        v_rcpt_type := 'NF';
                     ELSE
                        v_rcpt_type := '';
                     END IF;


                     DBMS_OUTPUT.put_line
                                     ('Step 11 >> Start Policy Issuance ==>11');
DBMS_OUTPUT.put_line
                                     ('Step 11 >> p_error_code= '||p_error_code);
                     IF p_error_code = 0 THEN
DBMS_OUTPUT.PUT_LINE('INSIDE BJAZ_LEXUS_WEBSERVICE.issue_motor_policy 2520 ');
                        customer.BJAZ_LEXUS_WEBSERVICE.issue_motor_policy
                                                       (LEXUS_user_name,
                                                        p_rcpt_list,
                                                        p_cust_details,
                                                        p_weo_mot_policy_in,
                                                        accessories_list,
                                                        paddoncover_list,
                                                        mot_extra_cover,
                                                        premium_details_out,
                                                        premium_summery_list,
                                                        p_quest_list,
                                                        ppolicyref,
                                                        ppolicyissuedate,
                                                        ppart_id, p_error,
                                                        p_error_code,
                                                        ppremiumpayerid,
                                                        paymentmode,
                                                        locationid,
                                                        potherdetails,
                                                        p_instrument_type,
                                                        v_scrutiny_no,v_rcpt_type,
                                                        v_stax_dtls,
                                                        v_stax_dtls_basic_tp,
                                                        v_stax_dtls_other_tp);
DBMS_OUTPUT.PUT_LINE('BJAZ_LEXUS_WEBSERVICE 2545 ppolicyref= '||ppolicyref);
                     ELSE
                        error_comments :=
                              'EXCEPTION FOUND BEFORE ISSUE MOTOR POLICY'
                           || 'P_ERROR_CODE = '
                           || p_error_code
                           || ' AND V_POL_COUNT = '
                           || v_pol_count;
                        p_error_code := 1;
                        save_error_code (lpol.transactionid, p_error_code,
                                         error_comments);
                        error_comments := NULL;
                        RETURN;
                     END IF;

                     DBMS_OUTPUT.put_line
                               (   'Step 11 >> Start Policy Issuance ==>13.1 '
                                || ppolicyref);
                     DBMS_OUTPUT.put_line
                               (   'Step 11 >> Start Policy Issuance ==>13.2 '
                                || p_error_code);

                     IF p_error_code = 0 THEN
                        IF ppolicyref IS NULL THEN
                           bjaz_marsh_utils.clear_failed_policy
                                                         (lpol.transactionid,
                                                          'LEXUS',
                                                          v_scrutiny_no);

                           IF p_error.COUNT () > 0 THEN
                              FOR i IN 1 .. p_error.COUNT () LOOP
                                 UPDATE bjaz_LEXUS_ws_data
                                 SET error_desc =
                                           error_desc
                                        || ' + '
                                        || p_error (i).err_text
                                 WHERE  transactionid = lpol.transactionid;
                 COMMIT;
                              END LOOP;

                              RETURN;
                           END IF;

                           error_comments :=
                                   'POLICY NUMBER RETURN IS NULL' || v_err_msg;
                           p_error_code := 1;
                           save_error_code (lpol.transactionid, p_error_code,
                                            error_comments);
                           error_comments := NULL;
                           RETURN;
                        END IF;

                        IF ppolicyref IS NOT NULL THEN
                           UPDATE bjaz_LEXUS_ws_data
                           SET error_desc = NULL
                           WHERE  transactionid = lpol.transactionid;
               COMMIT;
                        END IF;

                        DBMS_OUTPUT.put_line
                                 (   'Step 11 >> Start Policy Issuance ==>14 '
                                  || ppolicyref);

                        UPDATE bjaz_LEXUS_ws_data
                        SET bjazpolicyno = ppolicyref,
                            processed = 'Y',
                            bjaz_receipt = reciept_mst.receipt_no,
                            bjaz_partner_id = bjaz_ski_part.bjaz_part_id,
                            bjaz_premium = premium_details_out.final_premium,
                            --record_date = SYSDATE,
                            ERROR_CODE = NULL
                            --step_code = NULL
                        WHERE  transactionid = lpol.transactionid;

                        UPDATE ocp_policy_versions
                        SET business_start_date = TRUNC(TO_DATE(lpol.inspolicyeffectivedate,'MM/DD/YYYY HH24:MI:SS'))
                        WHERE  contract_id =
                                  (SELECT contract_id
                                   FROM   ocp_policy_bases
                                   WHERE  policy_ref = ppolicyref
                                          AND top_indicator = 'Y')
                               AND version_no = 1;

                        COMMIT;
                     ELSE
                        UPDATE bjaz_LEXUS_ws_data
                        SET bjaz_veh_code = NULL
                        WHERE  transactionid = lpol.transactionid;

                        COMMIT;

                        IF p_error.COUNT () > 0 THEN
                           FOR i IN 1 .. p_error.COUNT () LOOP
                              error_comments :=
                                    'KINDLY CHECK POLICY DETAILS '
                                 || p_error (i).err_text ||'-'||bjaz_mov_routes.gv_error_message;--changes for 57420986 - Proper Error message need to provide on interface/report
                              p_error_code := 1;
                              save_error_code (lpol.transactionid,
                                               p_error_code, error_comments);
                              RETURN;
                           END LOOP;
                        END IF;
                     END IF;
                  END;
               /*End:Issue Motor Policy*/
               EXCEPTION
                  WHEN OTHERS THEN
                    --abhi_error_msg.abhi_error_log('bjaz_lexus_webservice');
                     UPDATE bjaz_LEXUS_ws_data
                     SET error_desc =
                            error_desc || 'KINDLY CHECK POLICY DETAILS '--changes for 57420986 - Proper Error message need to provide on interface/report
                     WHERE  transactionid = lpol.transactionid;

                     CONTINUE;
               END;

               BEGIN
                 UPDATE ocp_policy_bases
                          SET term_start_date = TRUNC(to_date(lpol.inspolicyeffectivedate,'MM/DD/YYYY HH24:MI:SS')),
                                 term_end_date =CASE WHEN NVL(v_tpcurrent_policy_tenure,1) >1 THEN ADD_MONTHS (TRUNC(to_date(lpol.inspolicyeffectivedate,'MM/DD/YYYY HH24:MI:SS')), v_tpcurrent_policy_tenure * 12) - 1
                                                            ELSE TRUNC(to_date(lpol.inspolicyexpirydate,'MM/DD/YYYY HH24:MI:SS')) END
                    WHERE policy_ref = ppolicyref;

                  IF NVL (lpolextn.iscpa_dl_exist, 0) = 0 --akshay
                  AND NVL (lpolextn.cpa_current_tenure, '0') = '0'
               THEN
                  UPDATE bjaz_mot_cover_extn
                     SET tyre1 = 'DRVL'
                   WHERE     cover_code = 'ACT'
                         AND contract_id IN (SELECT contract_id
                                               FROM ocp_policy_bases
                                              WHERE policy_ref = ppolicyref);
               END IF;

                IF NVL (lpolextn.cpa_current_tenure, 0) <> 0
               THEN
                  UPDATE bjaz_mot_cover_extn
                     SET tyre1 = lpolextn.cpa_current_tenure
                   WHERE     cover_code = 'PA_DFT'
                         AND contract_id IN (SELECT contract_id
                                               FROM ocp_policy_bases
                                              WHERE policy_ref = ppolicyref);
               END IF;
                    COMMIT;
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

            END LOOP;
         EXCEPTION
            WHEN OTHERS THEN
             -- abhi_error_msg.abhi_error_log('2696 bjaz_lexus_webservice');
               UPDATE bjaz_LEXUS_ws_data
               SET error_desc =
                            error_desc || 'KINDLY CHECK POLICY DETAILS '
               WHERE  transactionid = lpol.transactionid;--changes for 57420986 - Proper Error message need to provide on interface/report

               CONTINUE;
         END;
      END LOOP;
   END upload_policy;

   PROCEDURE upd_LEXUS_branch_code (
      p_LEXUSpono   IN   VARCHAR2 DEFAULT NULL
   )
   AS
      PRAGMA AUTONOMOUS_TRANSACTION;
      v_bagic_loc_code   bjaz_sub_dealer_dtls.bagic_loc_code%TYPE;
   BEGIN
      IF p_LEXUSpono IS NOT NULL THEN
         SELECT z.bjaz_loc_code
         INTO   v_bagic_loc_code
         FROM   bjaz_LEXUS_ws_data x, bjaz_mibl_dealermast_dtls z
         WHERE  x.transactionid = p_LEXUSpono AND x.bjazpolicyno IS NULL
                --AND NVL (x.cancel_stat, 'N') = 'N'
                AND x.inspolicyissuingdealercode = z.dealer_code;

         DBMS_OUTPUT.put_line ('within branch_code 1');

         IF NVL (v_bagic_loc_code, 'X') = 'X' THEN
            save_error_code (p_LEXUSpono, 1,
                             'DATA NOT FOUND WHILE UPDATING BRANCH LOCATION ');
            --COMMIT;
            RETURN;
         END IF;

         DBMS_OUTPUT.put_line ('within branch_code 2 ' || v_bagic_loc_code);

         UPDATE bjaz_LEXUS_ws_data
         SET bjaz_loc_code = v_bagic_loc_code,
             ERROR_CODE = CASE
                            WHEN v_bagic_loc_code IS NULL THEN 109
                            ELSE NULL
                         END
         WHERE  transactionid = p_LEXUSpono;

         COMMIT;
         DBMS_OUTPUT.put_line ('within branch_code 3');
      END IF;
   -- COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         save_error_code (p_LEXUSpono, 1,
                          'EXCEPTION FOUND WHILE UPDATING BRANCH LOCATION ');
         COMMIT;
         RETURN;
   END upd_LEXUS_branch_code;

   PROCEDURE upd_LEXUS_vcode (
      p_LEXUSpono   IN   VARCHAR2 DEFAULT NULL
   )
   AS
      PRAGMA AUTONOMOUS_TRANSACTION;
      bjaz_vcode       VARCHAR2 (100)                                 := NULL;
      v_cubiccap       bjaz_vehicle_model_master.cubic_capacity%TYPE;
      v_seatingcap     bjaz_vehicle_model_master.carrying_capacity%TYPE;
      vxh_cc           VARCHAR2 (5);
      vxb_cc           VARCHAR2 (5);
      v_vehicleclass   VARCHAR2 (5);

      CURSOR c_hsci
      IS

     SELECT transactionid, modelcode, variantcode, cc, seatingcapacity,
                vehicleclass
         FROM   bjaz_LEXUS_ws_data
         WHERE  transactionid = p_LEXUSpono and  bjazpolicyno IS NULL;   ---- added for 54251156 -- Performance tuning LEXUS policy issuance

        --- SELECT transactionid, modelcode, variantcode, cc, seatingcapacity,
        ---        vehicleclass
        --- FROM   bjaz_LEXUS_ws_data
        --- WHERE  bjaz_veh_code IS NULL
        ---        AND ((1 = CASE
        ---                    WHEN p_LEXUSpono IS NULL THEN 1
        ---                    ELSE 0
        ---                 END) OR (transactionid = p_LEXUSpono)
        ---            )
        ---        AND bjazpolicyno IS NULL;
   BEGIN
      FOR i IN c_hsci LOOP
         BEGIN

dbms_output.put_line('cc= '||i.cc);
dbms_output.put_line('modelcode= '||i.modelcode);
dbms_output.put_line('variantcode= '||i.variantcode);
dbms_output.put_line('vehicleclass= '||i.vehicleclass);
            SELECT TRIM (vcode)
            INTO   bjaz_vcode
            FROM   bjaz_mibl_variant_dtls
            WHERE  cc = i.cc AND model_code = i.modelcode
                   AND variant_code = i.variantcode
                   AND veh_type = i.vehicleclass AND top_indicator = 'Y'
                   AND tieup = 'LEXUS';

            IF NVL (bjaz_vcode, 'X') = 'X' THEN
               save_error_code (p_LEXUSpono, 1, 'VEHICLE CODE IS NOT FOUND');
               --COMMIT;
               RETURN;
            END IF;

            IF bjaz_vcode IS NOT NULL OR p_LEXUSpono IS NOT NULL THEN
               UPDATE bjaz_LEXUS_ws_data
               SET bjaz_veh_code = bjaz_vcode
               WHERE  transactionid = i.transactionid AND bjazpolicyno IS NULL;

               COMMIT;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               save_error_code (p_LEXUSpono, 1,
                                'EXCEPTION FOUND WHILE UPDATING VEHICLE CODE');
               --COMMIT;
               RETURN;
         END;
      END LOOP;
   -- COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         save_error_code
                       (p_LEXUSpono, 1,
                        'EXCEPTION FOUND WHILE BAJAJ VEHICLE CODE UPDATION :');
         COMMIT;
         RETURN;
   END upd_LEXUS_vcode;

   PROCEDURE save_error_code (
      p_LEXUS_pono   IN   VARCHAR2,
      p_error_code    IN   NUMBER,
      p_error_desc    IN   VARCHAR2 DEFAULT NULL
   )
   AS
      PRAGMA AUTONOMOUS_TRANSACTION;
      v_scrutiny_no   VARCHAR2 (10);
   BEGIN
      UPDATE bjaz_LEXUS_ws_data
      SET ERROR_CODE = p_error_code,
          error_desc = p_error_desc
      WHERE  transactionid = p_LEXUS_pono;

      COMMIT;
      RETURN;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END save_error_code;

   PROCEDURE calculate_motor_premium (
      pidvvalue              IN       NUMBER,
      p_tieup_type           IN       VARCHAR2,
      p_weo_mot_policy_in    IN OUT   weo_mot_plan_details,
      accessories_list       IN OUT   weo_mot_accessories_list,
      paddoncover_list       IN OUT   weo_mot_gen_param_list,
      mot_extra_cover        IN       weo_sig_mot_extra_covers,
      phiddenvar             IN OUT   weo_mot_vechilepage_hidden_var,
      p_quest_list           IN OUT   weo_bjaz_mot_quest_list,
      premium_details_out    OUT      weo_mot_premium_details,
      premium_summery_list   OUT      weo_mot_premium_summary_list,
      p_stax_dtls            IN OUT   bjaz_service_tax_master_obj,
      p_error                OUT      weo_tyge_error_message_list,
      p_error_code           OUT      NUMBER,
      p_stax_dtls_basic_tp   IN OUT   bjaz_service_tax_master_obj,
      p_stax_dtls_other_tp   IN OUT   bjaz_service_tax_master_obj
   )
   AS
      extra_cover_fields   weo_mot_extra_cover_fields;
      vpos                 NUMBER;
      str                  VARCHAR2 (500);
      str1                 VARCHAR2 (500);
      v_licence_cnt        NUMBER;
      v_pa_period          NUMBER;
      v_od_policy_term     NUMBER;
      v_policy_period      NUMBER;
      v_final_premium      NUMBER                     := 0;
      v_term_start_date    DATE;
      v_net_prem           NUMBER;
      v_pincode            NUMBER;
      v_gst_no             VARCHAR2 (50);
      v_total_od_prem      NUMBER;
      v_total_act_prem     NUMBER;
      v_basic_act_prem     NUMBER;
      v_part_id            NUMBER;
      v_stamp_duty         VARCHAR2 (50);
      v_final_prem         NUMBER;
      v_ncb_amt            NUMBER;
      v_cust_pincode       NUMBER;
      v_pin_cnt            NUMBER                     := 0;
      v_cust_state         VARCHAR2 (200);
      v_add_id             cp_partners.add_id%TYPE;
      v_state_name         VARCHAR2 (200);
   BEGIN
dbms_output.put_line('
inside bjaz_lexus_web_service.calculate_motor_premium
');
      str := mot_extra_cover.geog_extn;
      extra_cover_fields :=
         weo_mot_extra_cover_fields (NULL, 0, 0, NULL, 0, 0, 0, 0, 0, 0, 0,
                                     0, NULL, NULL, NULL, NULL, NULL, NULL,
                                     NULL, NULL, NULL, NULL, NULL, NULL,
                                     NULL, NULL, NULL, NULL, NULL, NULL);

      FOR i IN 0 .. LENGTH (NVL (str, 0)) LOOP
         vpos := INSTR (str, ',');

         IF vpos > 0 THEN
            str1 := SUBSTR (str, 1, vpos - 1);
            extra_cover_fields.geog_list (i).country := str1;
            str := SUBSTR (str, vpos + 1, LENGTH (str));
         END IF;
      END LOOP;

      extra_cover_fields.pa_named_list := weo_mot_pa_named_list ();
      extra_cover_fields.no_of_persons_pa := mot_extra_cover.no_of_persons_pa;
      extra_cover_fields.sum_insured_pa := mot_extra_cover.sum_insured_pa;
      extra_cover_fields.sum_insured_total_named_pa :=
                                    mot_extra_cover.sum_insured_total_named_pa;
      extra_cover_fields.cng_value := mot_extra_cover.cng_value;
      extra_cover_fields.no_of_employees_lle :=
                                           mot_extra_cover.no_of_employees_lle;
      extra_cover_fields.no_of_persons_llo :=
                                             mot_extra_cover.no_of_persons_llo;
      extra_cover_fields.fibre_glass_value :=
                                             mot_extra_cover.fibre_glass_value;
      extra_cover_fields.side_car_value := mot_extra_cover.side_car_value;
      extra_cover_fields.no_of_trailers := mot_extra_cover.no_of_trailers;
      extra_cover_fields.total_trailer_value :=
                                           mot_extra_cover.total_trailer_value;
      extra_cover_fields.voluntary_excess := mot_extra_cover.voluntary_excess;
      extra_cover_fields.covernote_no := mot_extra_cover.covernote_no;
dbms_output.put_line('extra_cover_fields.covernote_no= '||extra_cover_fields.covernote_no);
      extra_cover_fields.covernote_date := mot_extra_cover.covernote_date;
dbms_output.put_line('extra_cover_fields.covernote_date= '||extra_cover_fields.covernote_date);
      extra_cover_fields.extra1 := mot_extra_cover.extra_field1;
      extra_cover_fields.extra2 := mot_extra_cover.extra_field2;
dbms_output.put_line('extra_cover_fields.extra3= '||extra_cover_fields.extra3);
      extra_cover_fields.extra3 := mot_extra_cover.extra_field3;
dbms_output.put_line('extra_cover_fields.extra3= '||extra_cover_fields.extra3);
      /*PA DEALER ford */
      BEGIN
         SELECT NVL (iscpa_dl_exist, 1), cpa_current_tenure
         INTO   v_licence_cnt, v_pa_period
         FROM   bjaz_LEXUS_ws_data_extn
         WHERE  transactionid = gv_LEXUS_polno;
      EXCEPTION
         WHEN OTHERS THEN
            v_licence_cnt := 1;
      END;

      IF v_licence_cnt = 0 THEN
         extra_cover_fields.extra5 := 'N';
      ELSE
         extra_cover_fields.extra6 := TO_CHAR (v_pa_period);
      END IF;

     IF p_weo_mot_policy_in.product_4digit_code = 1827 THEN
--         p_weo_mot_policy_in.product_4digit_code := 1801;
         v_od_policy_term := 3;

         FOR k IN 1 .. v_od_policy_term LOOP
            IF k = 1 THEN
               BEGIN
                  SELECT vehicleidv,
                         nonelectricaccidv,
                         electricaccidv,
                         bifuelkitidv
                  INTO   p_weo_mot_policy_in.vehicle_idv,
                         p_weo_mot_policy_in.non_elec_acc_total,
                         p_weo_mot_policy_in.elec_acc_total,
                         extra_cover_fields.cng_value
                  FROM   bjaz_LEXUS_ws_data
                  WHERE  transactionid =
                                       BJAZ_LEXUS_WEBSERVICE.gv_LEXUS_polno;
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               v_policy_period := 1;
            ELSIF k = 2 THEN
               BEGIN
                  SELECT b.vehicleidv_year2,
                         b.nonelectricaccidv2,
                         b.electricaccidv2,
                         b.bifuelkitidv2
                  INTO   p_weo_mot_policy_in.vehicle_idv,
                         p_weo_mot_policy_in.non_elec_acc_total,
                         p_weo_mot_policy_in.elec_acc_total,
                         extra_cover_fields.cng_value
                  FROM   bjaz_lexus_ws_data b
                  WHERE  b.transactionid =
                                       BJAZ_LEXUS_WEBSERVICE.gv_LEXUS_polno;
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               v_policy_period := 2;
            ELSIF k = 3 THEN
               BEGIN
                  SELECT vehicleidv_year3,
                         nonelectricaccidv3,
                         electricaccidv3,
                         bifuelkitidv3
                  INTO   p_weo_mot_policy_in.vehicle_idv,
                         p_weo_mot_policy_in.non_elec_acc_total,
                         p_weo_mot_policy_in.elec_acc_total,
                         extra_cover_fields.cng_value
                  FROM   bjaz_LEXUS_ws_data
                  WHERE  transactionid =
                                       BJAZ_LEXUS_WEBSERVICE.gv_LEXUS_polno;
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               v_policy_period := 3;
            END IF;

            weo_mot_util.calculate_motor_premium
                                             (p_weo_mot_policy_in.vehicle_idv,
                                              p_weo_mot_policy_in,
                                              accessories_list,
                                              paddoncover_list,
                                              extra_cover_fields, phiddenvar,
                                              p_quest_list,
                                              premium_details_out,
                                              premium_summery_list,
                                              p_stax_dtls, p_error,
                                              p_error_code,
                                              p_stax_dtls_basic_tp,
                                              p_stax_dtls_other_tp,
                                              v_policy_period);

            IF extra_cover_fields.extra4 IS NOT NULL THEN
               gv_comm_disc_amt := extra_cover_fields.extra4;
            END IF;
         END LOOP;

         BEGIN
            SELECT bjaz_partid
            INTO   v_part_id
            FROM   bjaz_mibl_partner_tb
            WHERE  polno = BJAZ_LEXUS_WEBSERVICE.gv_LEXUS_polno;

            v_cust_pincode := bjaz_utils.get_partner_pincode (v_part_id);

            SELECT COUNT (1)
            INTO   v_pin_cnt
            FROM   azbj_pincode
            WHERE  pincode = v_cust_pincode;

            SELECT buyergstin, pincode, statecode
            INTO   v_gst_no, v_pincode, v_cust_state
            FROM   bjaz_LEXUS_ws_data a, bjaz_LEXUS_ws_data_extn b
            WHERE  a.transactionid = BJAZ_LEXUS_WEBSERVICE.gv_LEXUS_polno
                   AND a.transactionid = b.transactionid;

            SELECT add_id
            INTO   v_add_id
            FROM   cp_partners
            WHERE  part_id = v_part_id;

            IF v_pin_cnt = 0 THEN
               SELECT state_name
               INTO   v_state_name
               FROM   bjaz_mibl_state_dtls
               WHERE  state_code = v_cust_state AND tieup = 'LEXUS';

               SELECT pincode
               INTO   v_pincode
               FROM   azbj_pincode
               WHERE  UPPER (state) = v_state_name AND ROWNUM = 1;
            ELSE
               v_pincode := v_cust_pincode;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               SELECT pincode
               INTO   v_pincode
               FROM   bjaz_LEXUS_ws_data
               WHERE  transactionid = BJAZ_LEXUS_WEBSERVICE.gv_LEXUS_polno;
         END;

         IF v_policy_period = 3 THEN
            SELECT ROUND (SUM (od))
            INTO   v_total_od_prem
            FROM   bjaz_mibl_debug_tb
            WHERE  polno = BJAZ_LEXUS_WEBSERVICE.gv_LEXUS_polno;

            SELECT ROUND (SUM (act))
            INTO   v_basic_act_prem
            FROM   bjaz_mibl_debug_tb
            WHERE  polno = BJAZ_LEXUS_WEBSERVICE.gv_LEXUS_polno
                   AND param_ref = 'ACT';

            SELECT ROUND (SUM (od))
            INTO   v_ncb_amt
            FROM   bjaz_mibl_debug_tb
            WHERE  polno = BJAZ_LEXUS_WEBSERVICE.gv_LEXUS_polno
                   AND param_ref = 'NCB';

            SELECT ROUND (SUM (act))
            INTO   v_total_act_prem
            FROM   bjaz_mibl_debug_tb
            WHERE  polno = BJAZ_LEXUS_WEBSERVICE.gv_LEXUS_polno
                   AND param_ref <> 'ACT';

            v_net_prem :=
                         v_total_od_prem + v_basic_act_prem + v_total_act_prem;
         END IF;

         v_term_start_date :=
                  TO_DATE (p_weo_mot_policy_in.term_start_date, 'DD-MON-YYYY');
         p_weo_mot_policy_in.product_4digit_code := 1827;
         ba_motor_utility.get_applicable_tax_motor
                    (p_contract_id => NULL, p_deptcode => 18,
                     p_product_code => 1827,
                     p_term_start_date => v_term_start_date,
                     p_ph_add_id => NULL,
                     p_branch_code => p_weo_mot_policy_in.branch_code,
                     p_prem_amt => v_net_prem, p_username => 'MOTOR DEALER',
                     p_pincode => v_pincode, p_co_ins_type => NULL,
                     p_flag_business => NULL, p_exmpt_tax_yn => NULL,
                     p_refund_tax_code => NULL, p_partner_gstn => v_gst_no,
                     p_oem_name => 'LEXUS', p_tax_flag => NULL,
                     p_veh_type_code => p_weo_mot_policy_in.vehicle_type_code,
                     p_total_od => v_total_od_prem,
                     p_total_tp => v_total_act_prem,
                     p_basic_tp => v_basic_act_prem,
                     p_stax_dtls_od => p_stax_dtls,
                     p_stax_dtls_basic_tp => p_stax_dtls_basic_tp,
                     p_stax_dtls_other_tp => p_stax_dtls_other_tp);
         v_final_prem :=
            v_net_prem + NVL (p_stax_dtls.ser_tax, 0)
            + NVL (p_stax_dtls.edu_cess, 0) + NVL (p_stax_dtls.sb_tax, 0)
            + NVL (p_stax_dtls.kkc, 0) + NVL (p_stax_dtls.cess1, 0)
            + NVL (p_stax_dtls.cess2, 0) + NVL (p_stax_dtls.cess3, 0)
            + NVL (p_stax_dtls.sgst, 0) + NVL (p_stax_dtls.cgst, 0)
            + NVL (p_stax_dtls.igst, 0) + NVL (p_stax_dtls.ncc, 0)
            + NVL (p_stax_dtls.utgst, 0)
            + NVL (p_stax_dtls_basic_tp.ser_tax, 0)
            + NVL (p_stax_dtls_basic_tp.edu_cess, 0)
            + NVL (p_stax_dtls_basic_tp.sb_tax, 0)
            + NVL (p_stax_dtls_basic_tp.kkc, 0)
            + NVL (p_stax_dtls_basic_tp.cess1, 0)
            + NVL (p_stax_dtls_basic_tp.cess2, 0)
            + NVL (p_stax_dtls_basic_tp.cess3, 0)
            + NVL (p_stax_dtls_basic_tp.sgst, 0)
            + NVL (p_stax_dtls_basic_tp.cgst, 0)
            + NVL (p_stax_dtls_basic_tp.igst, 0)
            + NVL (p_stax_dtls_basic_tp.ncc, 0)
            + NVL (p_stax_dtls_basic_tp.utgst, 0)
            + NVL (p_stax_dtls_other_tp.ser_tax, 0)
            + NVL (p_stax_dtls_other_tp.edu_cess, 0)
            + NVL (p_stax_dtls_other_tp.sb_tax, 0)
            + NVL (p_stax_dtls_other_tp.kkc, 0)
            + NVL (p_stax_dtls_other_tp.cess1, 0)
            + NVL (p_stax_dtls_other_tp.cess2, 0)
            + NVL (p_stax_dtls_other_tp.cess3, 0)
            + NVL (p_stax_dtls_other_tp.sgst, 0)
            + NVL (p_stax_dtls_other_tp.cgst, 0)
            + NVL (p_stax_dtls_other_tp.igst, 0)
            + NVL (p_stax_dtls_other_tp.ncc, 0)
            + NVL (p_stax_dtls_other_tp.utgst, 0);
         v_stamp_duty :=
            bjaz_utils.get_param_value
                                     ('STAMP', 18,
                                      p_weo_mot_policy_in.product_4digit_code,
                                      v_term_start_date);
         v_final_prem := ROUND (v_final_prem, 0);
         v_final_premium := ROUND (v_final_prem, 0);
         premium_details_out :=
            weo_mot_premium_details (v_ncb_amt, 0, v_total_od_prem,
                                     v_total_act_prem, 0, v_net_prem,
                                     v_net_prem, v_final_premium, 0, 0,
                                     v_stamp_duty, 0, 0, 0);

         BEGIN
            premium_details_out.final_premium := v_final_premium;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
      ELSE
dbms_output.put_line('lexus webservice weo_mot_util.calculate_motor_premium STARTS');
         weo_mot_util.calculate_motor_premium (pidvvalue, p_weo_mot_policy_in,
                                            accessories_list,
                                            paddoncover_list,
                                            extra_cover_fields, phiddenvar,
                                            p_quest_list, premium_details_out,
                                            premium_summery_list, p_stax_dtls,
                                            p_error, p_error_code,
                                            p_stax_dtls_basic_tp,
                                            p_stax_dtls_other_tp);
dbms_output.put_line('lexus webservice weo_mot_util.calculate_motor_premium ENDS');

      IF p_error.COUNT () > 0 THEN
         FOR i IN 1 .. p_error.COUNT () LOOP
            DBMS_OUTPUT.put_line (p_error (i).err_text);
         END LOOP;
      END IF;

      IF extra_cover_fields.extra4 IS NOT NULL THEN
         gv_LEXUS_comm_disc_amt := extra_cover_fields.extra4;
      END IF;
   END IF;
   EXCEPTION
      WHEN OTHERS THEN
       -- abhi_error_msg.abhi_error_log('bjaz_lexus_web_service.calculate_motor_premium');
        NULL;
   END calculate_motor_premium;

   PROCEDURE add_partner (
      bjaz_ski_part   IN OUT   bjaz_ski_partner,
      p_error         OUT      weo_tyge_error_message_list,
      p_error_code    OUT      NUMBER
   )
   AS
      v_error         weo_tyge_error_message;
      vresult         VARCHAR2 (10);
      presult         VARCHAR2 (10);
      p_part_dtls     weo_rec_strings10;
      p_pid_result    NUMBER;
      v_visofnumber   VARCHAR2 (100);
      v_tieup_name    VARCHAR2 (30);
   BEGIN
      p_error := weo_tyge_error_message_list ();
      p_part_dtls :=
         weo_rec_strings10 (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                            NULL, NULL);
      v_visofnumber := bjaz_ski_part.ski_part_id;

      BEGIN
         SELECT NVL (bjaz_partid, 0)
         INTO   bjaz_ski_part.bjaz_part_id
         FROM   bjaz_mibl_partner_tb
         WHERE  polno = bjaz_ski_part.ski_part_id AND top_indicator = 'Y'
                AND tieup_name = 'LEXUS';

         IF bjaz_ski_part.bjaz_part_id <> 0 THEN
            p_error_code := 0;
            RETURN;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END;

      vresult :=
         jsp_pp_nb.modaddpartner
             ('A', bjaz_ski_part.partner_type,                 -- Partner type
              bjaz_ski_part.address_line1,                   -- address line 1
              bjaz_ski_part.address_line2,                   -- address line 2
              bjaz_ski_part.city,                            -- address line 3
              bjaz_ski_part.state,                                    -- state
              bjaz_ski_part.landmark,                             -- pLandmark
              bjaz_ski_part.area,                                    -- apArea
              bjaz_ski_part.pin_code,                              -- pin code
              bjaz_ski_part.telephone,                            -- telephone
              bjaz_ski_part.telephone2,                         -- telephone 2
              bjaz_ski_part.moblie_no,                             --mobile no
              bjaz_ski_part.email, bjaz_ski_part.before_title,
              bjaz_ski_part.first_name, bjaz_ski_part.middle_name,
              bjaz_ski_part.sur_name,                              -- sur name
              bjaz_ski_part.sex,                                        -- sex
              NULL,                            --p_details.quality, -- quality
              NULL,                                     --p_details.literature
              NULL,                                     --p_details.occupation
              NULL,                                              --pDrvLicense
              NULL,                                              --pExpiryDate
              NULL,                                                   --pAamNo
              NULL,              --p_details.marital_status, -- martial status
              TO_CHAR (TO_DATE (bjaz_ski_part.date_of_birth, 'DD-MON-RRRR'),
                       'DD-MON-RRRR'),                        -- date of birth
              NULL,                                            --pPlaceOfBirth
              bjaz_ski_part.parent_co, bjaz_ski_part.parent_id,

              --NULL,--pParentId
              bjaz_ski_part.institution_name,              -- institution_name
              bjaz_ski_part.reg_no,                         -- inst reg number
              NULL,                                         --,pGlobalCompName
              NULL,                                              --pCompNumber
              bjaz_ski_part.addressee,                            --pAddressee
              bjaz_ski_part.p_buisness,                    --NULL,--pBussiness
              NULL,                                                  --pPartId
              presult);

      --Changes done for call no 46766871
      IF vresult = 2 THEN
         p_error_code := 1;
         p_part_dtls.stringval1 := bjaz_ski_part.ski_part_id;
         p_part_dtls.stringval2 := vresult;
         p_part_dtls.stringval3 :=
            'Customer Name should not contain keywords like pvt,ltd,private,limited,company,co.,m/s ..';
         save_error_code (v_visofnumber, 1,
                          'EXCEPTION FOUND WHILE ADDING PARTNER ');--changes for 57420986 - Proper Error message need to provide on interface/report
         COMMIT;
         RETURN;
      ELSIF presult != 0 THEN
         p_error_code := 1;
         p_part_dtls.stringval1 := bjaz_ski_part.ski_part_id;
         p_part_dtls.stringval2 := vresult;
         p_part_dtls.stringval3 :=
                                 'ERROR : INSUFFICIENT PARTNER DATA UPLOADED';
         save_error_code (v_visofnumber, 1,
                          'EXCEPTION FOUND WHILE ADDING PARTNER ');--changes for 57420986 - Proper Error message need to provide on interface/report
         COMMIT;
         RETURN;
      ELSE
         UPDATE azbj_partner_extn
         SET paidup_capital = bjaz_ski_part.paidup_capital
         WHERE  part_id = vresult;

         p_part_dtls.stringval1 := bjaz_ski_part.ski_part_id;
         p_part_dtls.stringval2 := vresult;
         p_part_dtls.stringval3 := 'SUCCESS';
         p_part_dtls.stringval4 := 'LEXUS';
         p_pid_result :=
                     BJAZ_LEXUS_WEBSERVICE.ins_partner_dtls_tb (p_part_dtls);
      END IF;

      bjaz_ski_part.bjaz_part_id := vresult;
      p_error_code := 0;
   EXCEPTION
      WHEN OTHERS THEN
         save_error_code (v_visofnumber, 1,
                          'EXCEPTION FOUND WHILE ADDING PARTNER '); --changes for 57420986 - Proper Error message need to provide on interface/report
         COMMIT;
         RETURN;
   END add_partner;

   FUNCTION ins_partner_dtls_tb (
      p_part_dtls   IN   weo_rec_strings10
   )
      RETURN NUMBER
   AS
      PRAGMA AUTONOMOUS_TRANSACTION;
      v_pid_cnt   NUMBER (8);
   BEGIN
      SELECT COUNT (*)
      INTO   v_pid_cnt
      FROM   bjaz_mibl_partner_tb
      WHERE  polno = p_part_dtls.stringval1 AND top_indicator = 'Y'
             AND tieup_name = 'LEXUS' AND ROWNUM < 2;

      IF v_pid_cnt > 0 THEN
         INSERT INTO bjaz_mibl_partner_tb
                     (polno, version_no, bjaz_partid, record_date,
                      bjaz_comments, top_indicator, tieup_name)
            SELECT polno, (SELECT MAX (version_no) + 1
                           FROM   bjaz_mibl_partner_tb
                           WHERE  polno = p_part_dtls.stringval1),
                   bjaz_partid, record_date, NULL, 'W', 'LEXUS'
            FROM   bjaz_mibl_partner_tb
            WHERE  polno = p_part_dtls.stringval1 AND top_indicator = 'Y';

         UPDATE bjaz_mibl_partner_tb
         SET top_indicator = 'N'
         WHERE  top_indicator = 'Y' AND polno = p_part_dtls.stringval1
                AND tieup_name = 'LEXUS';

         UPDATE bjaz_mibl_partner_tb
         SET top_indicator = 'Y',
             bjaz_partid = p_part_dtls.stringval2,
             bjaz_comments = p_part_dtls.stringval3,
             record_date = SYSDATE
         WHERE  top_indicator = 'W' AND polno = p_part_dtls.stringval1
                AND tieup_name = 'LEXUS';

         COMMIT;
      ELSE
         INSERT INTO bjaz_mibl_partner_tb
                     (polno, version_no, bjaz_partid,
                      record_date, bjaz_comments, top_indicator, tieup_name
                     )
         VALUES      (p_part_dtls.stringval1, 1, p_part_dtls.stringval2,
                      SYSDATE, p_part_dtls.stringval3, 'Y', 'LEXUS'
                     );

         COMMIT;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         UPDATE bjaz_LEXUS_ws_data
         SET error_desc = error_desc || ' EXCEPTION WHILE INSERTING PARTNER '
         WHERE  transactionid = p_part_dtls.stringval1;--changes for 57420986 - Proper Error message need to provide on interface/report

         RETURN 1;
   END ins_partner_dtls_tb;

   PROCEDURE issue_reciept (
      p_tieup_type      IN       VARCHAR2,
      user_name         IN       VARCHAR2,
      pol_type          IN       VARCHAR2 DEFAULT 'POLICY',
      p_scr_dtls_list   IN       weo_rec_strings40_list,
      PASSWORD          IN       VARCHAR2,
      location_code     IN       VARCHAR2,
      reciept_mst       IN OUT   bjaz_ski_reciept_mst,
      inst_list         IN OUT   bjaz_ski_instument_list,
      prod_list         IN OUT   bjaz_ski_product_list,
      p_error           OUT      weo_tyge_error_message_list,
      p_error_code      OUT      NUMBER
   )
   AS
      v_error          weo_tyge_error_message;
      prcpt_obj        bjaz_accr_rcpt_obj;
      pinstr_list      bjaz_accr_instr_obj_list;
      pcontrol_obj     bjaz_accr_control_obj;
      v_count          NUMBER (5);
      p_receipt_dtls   weo_rec_strings10;
      v_rcpt_rslt      NUMBER;
      p_error_mesg     VARCHAR2 (4000);
      p_field_list     bjaz_gen_fields_list     DEFAULT NULL;
      p_pdc_dtls       weo_rec_strings10        DEFAULT NULL;
      p_scr_rcpt_obj   weo_rec_strings20        DEFAULT NULL;
      v_visofnumber    VARCHAR2 (100);
   BEGIN
      p_error := weo_tyge_error_message_list ();
      pinstr_list := bjaz_accr_instr_obj_list ();
      p_receipt_dtls :=
         weo_rec_strings10 (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                            NULL, NULL);
      v_visofnumber := reciept_mst.ski_receipt_no;
      DBMS_OUTPUT.put_line ('Step 10 >> v_visofnumber ' || v_visofnumber);

      IF inst_list.COUNT > 1 THEN
         v_error :=
            weo_tyge_error_message
               (1001, 'bjaz_dfs_utils', NULL, NULL,
                'Multiple Instruments in one receipt is not allowed. Pls Check.',
                1);
         p_error.EXTEND;
         p_error (p_error.COUNT ()) := v_error;
         p_error_code := 1;
         RETURN;
      END IF;

      DECLARE
         v_receipt_amt   bjaz_receipts.trans_amount%TYPE;
      BEGIN
         SELECT x1.bjaz_receipt, x2.trans_amount
         INTO   reciept_mst.receipt_no, v_receipt_amt
         FROM   bjaz_mibl_ws_receipt_tb x1, bjaz_receipts x2
         WHERE  polno = reciept_mst.ski_receipt_no AND x1.top_indicator = 'Y'
                AND bjaz_receipt = receipt_no AND tieup_name = p_tieup_type
                AND receipt_req_id IS NULL;

         DBMS_OUTPUT.put_line (   'Step 10 >> reciept_mst.receipt_no '
                               || reciept_mst.receipt_no);
         DBMS_OUTPUT.put_line ('Step 10 >> v_receipt_amt ' || v_receipt_amt);
         DBMS_OUTPUT.put_line (   'Step 10 >> reciept_mst.ski_receipt_no '
                               || reciept_mst.ski_receipt_no);
         DBMS_OUTPUT.put_line ('Step 10 >> p_tieup_type ' || p_tieup_type);

         IF v_receipt_amt >= inst_list (1).instr_amt THEN
            p_error_code := 0;
            RETURN;
         ELSE
            reciept_mst.receipt_no := NULL;

            UPDATE bjaz_mibl_ws_receipt_tb
            SET polno = 'R_' || reciept_mst.ski_receipt_no
            WHERE  polno = reciept_mst.ski_receipt_no AND top_indicator = 'Y'
                   AND tieup_name = p_tieup_type;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END;

      DBMS_OUTPUT.put_line ('Step 10 >> reciept_mst.receipt_no 2');
      prcpt_obj :=
         bjaz_accr_rcpt_obj (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL, NULL);
      prcpt_obj.partner_id := reciept_mst.partner_id;
      prcpt_obj.partner_type := reciept_mst.partner_type;
      prcpt_obj.imd_code := reciept_mst.imd_code;

      IF reciept_mst.type_of_receipt IS NULL THEN
         prcpt_obj.receipt_type := 'CUSTFLOAT';
      ELSE
         prcpt_obj.receipt_type := reciept_mst.type_of_receipt;
      END IF;

      DBMS_OUTPUT.put_line ('Step 10 >> reciept_mst.receipt_no 3');
      weo_accr_util.accr_get_partner_name (reciept_mst.partner_id,
                                           prcpt_obj.partner_name);
      pcontrol_obj :=
         bjaz_accr_control_obj (NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                NULL, NULL, NULL, NULL, NULL);
      DBMS_OUTPUT.put_line ('Step 10 >> reciept_mst.receipt_no 4');

      FOR i IN 1 .. inst_list.COUNT () LOOP
         pinstr_list.EXTEND;
         DBMS_OUTPUT.put_line (   'Step 10 >> inst_list (i).instr_type '
                               || inst_list (i).instr_type);

         IF inst_list (i).instr_type = 'CH' THEN
            pinstr_list (i) :=
               bjaz_accr_instr_obj (reciept_mst.partner_id,
                                    inst_list (i).instr_type,
                                    TO_CHAR (inst_list (i).instr_amt),
                                    TO_CHAR (inst_list (i).collection_no),
                                    inst_list (i).debit_to_bank,
                                    inst_list (i).bank_name,
                                    inst_list (i).bank_branch_name,
                                    inst_list (i).instr_number,
                                    inst_list (i).instr_date,
                                    inst_list (i).cheque_type, NULL, NULL,
                                    NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                    NULL, NULL, NULL, NULL, NULL, NULL,
                                    reciept_mst.imd_code, NULL, NULL, NULL,
                                    NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                    NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                    NULL, NULL, NULL, NULL, NULL, NULL);
         ELSIF inst_list (i).instr_type = 'CC' THEN
            pinstr_list (i) :=
               bjaz_accr_instr_obj (reciept_mst.partner_id,
                                    inst_list (i).instr_type,
                                    TO_CHAR (inst_list (i).instr_amt),
                                    TO_CHAR (inst_list (i).collection_no),
                                    NULL, inst_list (i).bank_name,
                                    inst_list (i).bank_branch_name,
                                    inst_list (i).instr_number,
                                    inst_list (i).instr_date,
                                    inst_list (i).cheque_type, NULL, NULL,
                                    NULL, NULL, NULL, NULL, NULL,
                                    inst_list (i).instr_number, NULL,
                                    inst_list (i).instr_date, NULL, NULL,
                                    NULL, NULL, NULL, reciept_mst.imd_code,
                                    NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                    NULL, NULL, NULL,
                                    inst_list (i).debit_to_bank, NULL, NULL,
                                    NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                    NULL, NULL, NULL);

         ELSIF inst_list (i).instr_type = 'OL'
         THEN
dbms_output.put_line('3551 instr_type = '||'OL'||' inst_list (i).instr_date= '||inst_list (i).instr_date);
dbms_output.put_line('3551 instr_type = '||'OL'||' inst_list (i).debit_to_bank= '||inst_list (i).debit_to_bank);
            pinstr_list (i) :=
               bjaz_accr_instr_obj (reciept_mst.partner_id,
                                    inst_list (i).instr_type,
                                    TO_CHAR (inst_list (i).instr_amt),
                                    TO_CHAR (inst_list (i).collection_no),
                                    inst_list (i).debit_to_bank,
                                    inst_list (i).bank_name,
                                    inst_list (i).bank_branch_name,
                                   'LEXUS-ONILINE',
                                    inst_list (i).instr_date,
                                    inst_list (i).cheque_type,
                                    --INST_LIST(i).MICR_NUMBER,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    inst_list (i).instr_number,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    reciept_mst.imd_code,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL);
         ELSE
            pinstr_list (i) :=
               bjaz_accr_instr_obj (reciept_mst.partner_id,
                                    inst_list (i).instr_type,
                                    TO_CHAR (inst_list (i).instr_amt),
                                    TO_CHAR (inst_list (i).collection_no),
                                    NULL, inst_list (i).bank_name,
                                    inst_list (i).bank_branch_name,
                                    inst_list (i).instr_number,
                                    inst_list (i).instr_date,
                                    inst_list (i).cheque_type, NULL, NULL,
                                    NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                    NULL, NULL, NULL, NULL, NULL, NULL,
                                    reciept_mst.imd_code, NULL, NULL, NULL,
                                    NULL, NULL, NULL, NULL, NULL, NULL,
                                    inst_list (i).debit_to_bank, NULL, NULL,
                                    NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                    NULL, NULL, NULL, NULL);
         END IF;
      END LOOP;

      DBMS_OUTPUT.put_line (   'Step 10 >> reciept_mst.receipt_status '
                            || reciept_mst.receipt_status);
      DBMS_OUTPUT.put_line (   'Step 10 >> prcpt_obj.receipt_type 1 '
                            || prcpt_obj.receipt_type);


      IF reciept_mst.receipt_status = 'P' THEN

         IF prcpt_obj.receipt_type = 'CUSTFLOAT' THEN
            FOR i IN 1 .. pinstr_list.COUNT () LOOP
/*pinstr_list (i).instr_date:=to_char(TO_DATE(pinstr_list (i).instr_date,'MM/DD/YYYY'));*/
               prcpt_obj.rcpt_date := pinstr_list (i).instr_date;

            END LOOP;

DBMS_OUTPUT.PUT_LINE('3631 prcpt_obj.rcpt_date= '||prcpt_obj.rcpt_date);
            DBMS_OUTPUT.put_line ('Step 10 >> prcpt_obj.receipt_type 6 ');
            weo_accr_receipt.custfloat_receipt (user_name, location_code,
                                                prcpt_obj, pinstr_list,
                                                pcontrol_obj, p_error,
                                                p_error_code, p_field_list,
                                                p_pdc_dtls, p_scr_dtls_list,
                                                p_scr_rcpt_obj);
            DBMS_OUTPUT.put_line
                   (   'Step 10 >> prcpt_obj.receipt_type 6**** p_error_code '
                    || p_error_code);
         ELSIF prcpt_obj.receipt_type = 'FLOAT' THEN
            DBMS_OUTPUT.put_line ('Step 10 >> prcpt_obj.receipt_type 7 ');
            weo_accr_receipt.float_receipt (user_name, location_code,
                                            prcpt_obj, pinstr_list,
                                            pcontrol_obj, NULL, p_error,
                                            p_error_code, p_field_list,
                                            p_scr_dtls_list, p_scr_rcpt_obj,
                                            NULL);
         END IF;
      ELSE
         weo_accr_receipt.generate_temporary_receipt (user_name,
                                                      location_code,
                                                      prcpt_obj, pinstr_list,
                                                      pcontrol_obj, p_error,
                                                      p_error_code,
                                                      p_field_list, NULL,
                                                      p_scr_dtls_list,
                                                      p_scr_rcpt_obj, NULL);
      END IF;

      DBMS_OUTPUT.put_line ('Step 10 >> prcpt_obj.receipt_type 8 ');

      FOR i IN 1 .. pinstr_list.COUNT LOOP
         SELECT COUNT (*)
         INTO   v_count
         FROM   bjaz_64vb_coll_stage
         WHERE  policy_ref = reciept_mst.ski_receipt_no
                AND cheque_no = pinstr_list (i).instr_number
                AND cheque_status = 'C' AND top_ind = 'Y' AND ROWNUM < 2;

         IF v_count <> 0 THEN
            INSERT INTO bjaz_64vb_coll_stage
                        (file_id, trans_id, version_no, deposit_sr_no,
                         receipt_no, cheque_no, cheque_date, cheque_amt,
                         cheque_status, trans_type, bank_name, branch_name,
                         banked_on, load_bank_id, load_date, branch_code,
                         policy_ref, duplicate_ind, top_ind, username,
                         entry_date, clear_type, clear_id, bounce_reason,
                         product, deposit_date)
               SELECT file_id, bjaz_seq_64vb_trans.NEXTVAL, 1, deposit_sr_no,
                      prcpt_obj.receipt_no, cheque_no, cheque_date,
                      cheque_amt, cheque_status, trans_type, bank_name,
                      branch_name, banked_on, load_bank_id, SYSDATE,
                      branch_code, policy_ref, duplicate_ind, top_ind,
                      username, SYSDATE, clear_type, clear_id, bounce_reason,
                      product, deposit_date
               FROM   bjaz_64vb_coll_stage
               WHERE  policy_ref = reciept_mst.ski_receipt_no
                      AND cheque_no = pinstr_list (i).instr_number
                      AND cheque_status = 'C' AND top_ind = 'Y'
                      AND ROWNUM = 1;

            UPDATE bjaz_receipts
            SET cheque_status = 'C'
            WHERE  receipt_no = prcpt_obj.receipt_no;
         END IF;
      END LOOP;

      DBMS_OUTPUT.put_line ('Step 10 >> prcpt_obj.receipt_type 9 ');

      FOR i IN 1 .. p_error.COUNT LOOP
         p_error_mesg := p_error_mesg || p_error (i).err_text;
      END LOOP;

      IF p_error_code != 0 THEN
         p_error_code := 1;
         save_error_code (reciept_mst.ski_receipt_no, p_error_code,
                          'ERROR IN CREATING RECEIPT ' || p_error_mesg);
         RETURN;
      ELSE
         reciept_mst.receipt_no := prcpt_obj.receipt_no;
         p_receipt_dtls.stringval1 := reciept_mst.ski_receipt_no;
         p_receipt_dtls.stringval2 := reciept_mst.receipt_no;
         p_receipt_dtls.stringval3 := reciept_mst.proposal_form_nos;
         p_receipt_dtls.stringval4 := reciept_mst.proposal_form_amt;
         p_receipt_dtls.stringval5 := reciept_mst.ski_agent_code;
         p_receipt_dtls.stringval6 := 'SUCCESS';
         v_rcpt_rslt :=
            BJAZ_LEXUS_WEBSERVICE.ins_receipt_dtls_tb (p_receipt_dtls,
                                                         p_tieup_type,
                                                         pol_type);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
         save_error_code (v_visofnumber, 1, 'EXCEPTION WHILE ISSUING RECEIPT');--changes for 57420986 - Proper Error message need to provide on interface/report
         RETURN;
   END issue_reciept;

   FUNCTION ins_receipt_dtls_tb (
      p_receipt_dtls   IN   weo_rec_strings10,
      p_tieup_type     IN   VARCHAR2,
      pol_type         IN   VARCHAR2 DEFAULT 'POLICY'
   )
      RETURN NUMBER
   AS
      PRAGMA AUTONOMOUS_TRANSACTION;
      v_rcpt_cnt   NUMBER (5);
   BEGIN
      SELECT COUNT (*)
      INTO   v_rcpt_cnt
      FROM   bjaz_mibl_ws_receipt_tb
      WHERE  polno = p_receipt_dtls.stringval1 AND top_indicator = 'Y'
             AND tieup_name = p_tieup_type AND ROWNUM < 2;

      IF v_rcpt_cnt > 0 THEN
         INSERT INTO bjaz_mibl_ws_receipt_tb
                     (polno, version_no, bjaz_receipt, record_date,
                      proposal_forms_no, proposal_form_amt, agent_code,
                      bjaz_comment, top_indicator, tieup_name)
            SELECT polno,
                   (SELECT MAX (NVL (version_no, 0)) + 1
                    FROM   bjaz_mibl_ws_receipt_tb
                    WHERE  polno = p_receipt_dtls.stringval1
                           AND tieup_name = p_tieup_type),
                   bjaz_receipt, SYSDATE, proposal_forms_no,
                   proposal_form_amt, agent_code, NULL, 'W', tieup_name
            FROM   bjaz_mibl_ws_receipt_tb
            WHERE  polno = p_receipt_dtls.stringval1 AND top_indicator = 'Y'
                   AND tieup_name = p_tieup_type;

         UPDATE bjaz_mibl_ws_receipt_tb
         SET top_indicator = 'N'
         WHERE  top_indicator = 'Y' AND polno = p_receipt_dtls.stringval1
                AND tieup_name = p_tieup_type;

         UPDATE bjaz_mibl_ws_receipt_tb
         SET top_indicator = 'Y',
             bjaz_receipt = p_receipt_dtls.stringval2,
             record_date = SYSDATE,
             proposal_forms_no = p_receipt_dtls.stringval3,
             proposal_form_amt = p_receipt_dtls.stringval4,
             agent_code = p_receipt_dtls.stringval5,
             bjaz_comment = p_receipt_dtls.stringval6
         WHERE  top_indicator = 'W' AND polno = p_receipt_dtls.stringval1
                AND tieup_name = p_tieup_type;

         COMMIT;
      ELSE
         INSERT INTO bjaz_mibl_ws_receipt_tb
                     (polno,
                      version_no,
                      bjaz_receipt, record_date,
                      proposal_forms_no, proposal_form_amt,
                      agent_code, bjaz_comment,
                      top_indicator, tieup_name
                     )
         VALUES      (p_receipt_dtls.stringval1,
                      (SELECT NVL (MAX (version_no), 0)
                       FROM   bjaz_mibl_ws_receipt_tb
                       WHERE  polno = p_receipt_dtls.stringval1
                              AND tieup_name = p_tieup_type),
                      p_receipt_dtls.stringval2, SYSDATE,
                      p_receipt_dtls.stringval3, p_receipt_dtls.stringval4,
                      p_receipt_dtls.stringval5, p_receipt_dtls.stringval6,
                      'Y', p_tieup_type
                     );

         COMMIT;
      END IF;

--      UPDATE bjaz_mibl_ws_receipt_tb
--      SET bjaz_receipt = p_receipt_dtls.stringval2
--      WHERE  polno = p_receipt_dtls.stringval1 AND tieup_name = p_tieup_type;
--
--      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 1;
   END ins_receipt_dtls_tb;

   PROCEDURE issue_motor_policy (
      puserid                IN       VARCHAR2,
      p_rcpt_list            IN OUT   weo_tyac_pay_list,
      p_cust_details         IN OUT   weo_b2c_cust_details,
      p_weo_mot_policy_in    IN OUT   weo_mot_plan_details,
      accessories_list       IN       weo_mot_accessories_list,
      paddoncover_list       IN       weo_mot_gen_param_list,
      mot_extra_cover        IN OUT   weo_sig_mot_extra_covers,
      premium_details        IN       weo_mot_premium_details,
      premium_summery_list   IN       weo_mot_premium_summary_list,
      p_quest_list           IN       weo_bjaz_mot_quest_list,
      ppolicyref             OUT      VARCHAR2,
      ppolicyissuedate       OUT      VARCHAR2,
      ppart_id               OUT      VARCHAR2,
      p_error                OUT      weo_tyge_error_message_list,
      p_error_code           OUT      NUMBER,
      ppremiumpayerid        IN       NUMBER,
      paymentmode            IN       VARCHAR2,
      locationid             IN       VARCHAR2,
      potherdetails          IN       weo_sig_other_details,
      p_instrument_type      IN       VARCHAR2,
      p_scrutiny_no          IN       VARCHAR2,
      v_flt_type             IN       VARCHAR2 DEFAULT NULL,
      p_stax_dtls            IN       bjaz_service_tax_master_obj,
      p_stax_dtls_basic_tp   IN       bjaz_service_tax_master_obj,
      p_stax_dtls_other_tp   IN       bjaz_service_tax_master_obj
   )
   AS
      v_error               weo_tyge_error_message;
      v_rcpt_obj            weo_tyac_pay_row;
      v_cov_status          VARCHAR2 (50);
      v_pol_no              VARCHAR2 (50);
      agn_flt_amt           NUMBER                                       := 0;
      rcpt_amt              NUMBER                                       := 0;
      v_nissan_premium      NUMBER;
      cust_flt_lst          weo_sig_cust_float_lst;
      vpos                  NUMBER;
      str                   VARCHAR2 (500);
      str1                  VARCHAR2 (500);
      extra_cover_fields    weo_mot_extra_cover_fields;
      v_cnt                 NUMBER (8);
      v_instrument_no       bjaz_receipts.instrument_no%TYPE;
      v_instrument_date     bjaz_receipts.instrument_date%TYPE;
      v_bank_name           bjaz_receipts.bank_name%TYPE;
      v_bank_branch_code    bjaz_receipts.bank_branch_code%TYPE;
      v_type_of_receipt     bjaz_receipts.type_of_receipt%TYPE;
      v_local_cheque_yn     bjaz_receipts.local_cheque_yn%TYPE;
      v_pay_event           VARCHAR2 (20);
      v_imd                 VARCHAR2 (20);
      pcontract_id          NUMBER;
      v_event               VARCHAR2 (20);
      v_batch_id            NUMBER;
      v_result              NUMBER;
      v_return              NUMBER;
      error_comments        VARCHAR2 (1000);
      scr_count             NUMBER (4);
      v_ret                 NUMBER;
      v_agent_balance       NUMBER                                       := 0;
      v_nf_balance          NUMBER                                       := 0;
      lmainagentcode        bjaz_policy_bases_extn.main_agent_code%TYPE;
      v_gross_premium       NUMBER                                       := 0;
      v_user_name           VARCHAR2 (100);
      v_pay_mode            VARCHAR2 (30);
      v_movement_batch_id   NUMBER;
      v_nfamt               NUMBER;
      v_hyundai_premium     NUMBER;
      v_from_scrutiny       NUMBER;
      v_start_time          VARCHAR2 (50);
      v_trans_time          DATE;
      v_proc_logs_flg       NUMBER                                       := 0;
      v_location_code       NUMBER                                       := 0;
      v_log_id              NUMBER                                       := 0;
      v_trans_tat_dtls      VARCHAR2 (500);
      v_si                  NUMBER;
      v_vehicle_type        VARCHAR2 (10);
      v_imt34tp             NUMBER;
      v_comm_desc           NUMBER;
      v_comm_desc_amt       NUMBER;
      v_oddiscount          NUMBER;
     -- v_adjust_cd_ld_disc   bjaz_LEXUS_ws_data_extn.adjust_cd_ld_disc%type;--akshay
      v_1827_policy         NUMBER                                       := 0;
      v_vehicleidv          NUMBER                                       := 0;
      v_vehicleidv2         NUMBER                                       := 0;
      v_vehicleidv3         NUMBER                                       := 0;
      v_prevcompname     VARCHAR2(100);--50338052
        v_financercode        NUMBER;
      v_nf_imd_code         VARCHAR2 (1000):=NULL;

      PROCEDURE addinerrlist (
         pmsg   IN   VARCHAR2
      )
      IS
      BEGIN
         v_error :=
            weo_tyge_error_message (1001, 'BJAZ_LEXUX_WEB_SERVICE', NULL,
                                    NULL, pmsg, 1);
         p_error.EXTEND;
         p_error (p_error.COUNT ()) := v_error;
         p_error_code := 1;
      END addinerrlist;
   BEGIN
      p_error_code := 0;
      p_error := weo_tyge_error_message_list ();
      DBMS_OUTPUT.put_line ('ISSUE MOTO POLICY sam--> 1' || p_error_code);
      DBMS_OUTPUT.put_line ('gv_LEXUS_pol_type --> 1' || gv_LEXUS_pol_type);
      DBMS_OUTPUT.put_line ('p_weo_mot_policy_in.pol_type --> 1' || p_weo_mot_policy_in.pol_type);

      IF p_weo_mot_policy_in.pol_type <> gv_LEXUS_pol_type THEN
         IF mot_extra_cover.covernote_no IS NOT NULL THEN
            BEGIN
               SELECT status, policy_ref
               INTO   v_cov_status, v_pol_no
               FROM   bjaz_covernote_status
               WHERE  covernote_no = mot_extra_cover.covernote_no;

               IF v_cov_status = 'I' THEN
                  addinerrlist (   'Policy No. '
                                || v_pol_no
                                || ' is already issued for this covernote - '
                                || mot_extra_cover.covernote_no);
                  COMMIT;
                  save_error_code (mot_extra_cover.covernote_no, 1,
                                      'Policy No. '
                                   || v_pol_no
                                   || ' is already issued for this covernote - ');
--ABHI_ERROR_MSG.abhi_error_log('BJAZ_LEXUS_WEBSERVICE.ISSUE_MOTOR_POLICY 3944');
                  RETURN;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  addinerrlist (   'Invalid covernote no - '
                                || mot_extra_cover.covernote_no);
                  COMMIT;
                  save_error_code (mot_extra_cover.covernote_no, 1,
                                      'Invalid covernote no - '
                                   || DBMS_UTILITY.format_error_stack
                                   || DBMS_UTILITY.format_error_backtrace);
--ABHI_ERROR_MSG.abhi_error_log('BJAZ_LEXUS_WEBSERVICE.ISSUE_MOTOR_POLICY 3956');
                  RETURN;
            END;
         END IF;

         DBMS_OUTPUT.put_line ('ISSUE MOTO POLICY --> 2' || p_error_code);

         IF p_instrument_type = 'AGNFLOAT' THEN
            agn_flt_amt :=
                   bjaz_hyundai_utils.get_agent_float (potherdetails.imdcode);

            IF (agn_flt_amt + 5) < premium_details.final_premium THEN
               addinerrlist
                  (   'ImdCode: '
                   || potherdetails.imdcode
                   || ' does not have sufficient float balance. The current balance is Rs.'
                   || agn_flt_amt
                   || ', while the premium is Rs.'
                   || premium_details.final_premium);
               COMMIT;
               save_error_code
                  (mot_extra_cover.covernote_no, 1,
                      'ImdCode: '
                   || potherdetails.imdcode
                   || ' does not have sufficient float balance. The current balance is Rs.'
                   || agn_flt_amt
                   || ', while the premium is Rs.'
                   || premium_details.final_premium);
--ABHI_ERROR_MSG.abhi_error_log('BJAZ_LEXUS_WEBSERVICE.ISSUE_MOTOR_POLICY 3984');
               RETURN;
            END IF;
         ELSE
            DBMS_OUTPUT.put_line ('ISSUE MOTO POLICY --> 3' || p_error_code);
            bjaz_hyundai_utils.get_br_cust_float_bal64vb
                                            (ppremiumpayerid,
                                             p_weo_mot_policy_in.branch_code,
                                             pme_public.opus_date,
                                             mot_extra_cover.covernote_no,
                                             cust_flt_lst);
            DBMS_OUTPUT.put_line ('p_rcpt_list>>' || p_rcpt_list.COUNT);

            FOR i IN 1 .. cust_flt_lst.COUNT LOOP

               <<l_p_rcpt_list>>
               FOR j IN 1 .. p_rcpt_list.COUNT LOOP
                  IF p_rcpt_list (j).receipt_no = cust_flt_lst (i).receipt_no THEN
                     rcpt_amt := rcpt_amt + cust_flt_lst (i).posting_amt;
                  END IF;
               END LOOP l_p_rcpt_list;
            END LOOP;

            DBMS_OUTPUT.put_line ('ISSUE MOTO POLICY --> 4' || p_error_code);

            IF (rcpt_amt + 5) < premium_details.final_premium THEN
               addinerrlist (   'Total Receipt/s Amount Rs.'
                             || rcpt_amt
                             || ' is less than Final Premium Rs.'
                             || premium_details.final_premium);
               COMMIT;
               save_error_code (mot_extra_cover.covernote_no, 1,
                                   'Total Receipt/s Amount Rs.'
                                || rcpt_amt
                                || ' is less than Final Premium Rs.'
                                || premium_details.final_premium);
--ABHI_ERROR_MSG.abhi_error_log('BJAZ_LEXUS_WEBSERVICE.ISSUE_MOTOR_POLICY 4020');
               RETURN;
            END IF;
         END IF;
      END IF;

      DBMS_OUTPUT.put_line ('ISSUE MOTO POLICY --> 5' || p_error_code);
      str := mot_extra_cover.geog_extn;
      extra_cover_fields :=
         weo_mot_extra_cover_fields (NEW weo_mot_geog_list (), 0, 0,
                                     NEW weo_mot_pa_named_list (), 0, 0, 0, 0,
                                     0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL,
                                     NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                     NULL, NULL, NULL, NULL, NULL, NULL);

      IF NOT str = '' THEN
         FOR i IN 0 .. LENGTH (str) LOOP
            vpos := INSTR (str, ',');

            IF vpos > 0 THEN
               str1 := SUBSTR (str, 1, vpos - 1);
               extra_cover_fields.geog_list (i).country := str1;
               str := SUBSTR (str, vpos + 1, LENGTH (str));
            END IF;
         END LOOP;
      END IF;

      DBMS_OUTPUT.put_line ('ISSUE MOTO POLICY --> 6' || p_error_code);
      extra_cover_fields.no_of_persons_pa := mot_extra_cover.no_of_persons_pa;

      IF mot_extra_cover.no_of_employees_lle = 0 THEN
         extra_cover_fields.no_of_employees_lle := NULL;
         mot_extra_cover.no_of_employees_lle := NULL;
      ELSE
         extra_cover_fields.no_of_employees_lle :=
                                          mot_extra_cover.no_of_employees_lle;
      END IF;

      IF mot_extra_cover.no_of_persons_llo = 0 THEN
         extra_cover_fields.no_of_persons_llo := NULL;
         mot_extra_cover.no_of_persons_llo := NULL;
      ELSE
         extra_cover_fields.no_of_persons_llo :=
                                            mot_extra_cover.no_of_persons_llo;
      END IF;

      extra_cover_fields.sum_insured_pa := mot_extra_cover.sum_insured_pa;
      extra_cover_fields.sum_insured_total_named_pa :=
                                    mot_extra_cover.sum_insured_total_named_pa;
      extra_cover_fields.cng_value := mot_extra_cover.cng_value;
      extra_cover_fields.fibre_glass_value :=
                                             mot_extra_cover.fibre_glass_value;
      extra_cover_fields.side_car_value := mot_extra_cover.side_car_value;
      extra_cover_fields.no_of_trailers := mot_extra_cover.no_of_trailers;
      extra_cover_fields.total_trailer_value :=
                                           mot_extra_cover.total_trailer_value;
      DBMS_OUTPUT.put_line ('ISSUE MOTO POLICY --> 7' || p_error_code);

      IF mot_extra_cover.voluntary_excess = 0 THEN
         extra_cover_fields.voluntary_excess := NULL;
         mot_extra_cover.voluntary_excess := NULL;
      ELSE
         extra_cover_fields.voluntary_excess :=
                                             mot_extra_cover.voluntary_excess;
      END IF;

      IF p_weo_mot_policy_in.misc_veh_type = 0 THEN
         p_weo_mot_policy_in.misc_veh_type := NULL;
      END IF;

      IF p_weo_mot_policy_in.prv_ins_company = 0 THEN
         p_weo_mot_policy_in.prv_ins_company := NULL;
      END IF;

      extra_cover_fields.covernote_no := mot_extra_cover.covernote_no;
      extra_cover_fields.covernote_date := mot_extra_cover.covernote_date;

      IF p_weo_mot_policy_in.tp_fin_type = 0 THEN
         p_weo_mot_policy_in.tp_fin_type := NULL;
      END IF;

      DBMS_OUTPUT.put_line ('ISSUE MOTO POLICY --> 8' || p_error_code);
      DBMS_OUTPUT.put_line (   'ISSUE MOTO POLICY --> 8.1 '
                            || p_weo_mot_policy_in.year_manf);
--      IF p_weo_mot_policy_in.year_manf IS NULL THEN
--         addinerrlist
--               ('Year of Manufacturing of the vehicle not found. Pls. check.');
--         COMMIT;
--         save_error_code
--               (mot_extra_cover.covernote_no, 1,
--                'Year of Manufacturing of the vehicle not found. Pls. check.');
--         RETURN;
--      END IF;
      DBMS_OUTPUT.put_line (   'p_weo_mot_policy_in.pol_type >>'
                            || p_weo_mot_policy_in.pol_type);
      DBMS_OUTPUT.put_line ('gv_LEXUS_pol_type >>' || gv_LEXUS_pol_type);
      DBMS_OUTPUT.put_line ('potherdetails.imdcode >>'
                            || potherdetails.imdcode);
      DBMS_OUTPUT.put_line ('potherdetails.imdcode >>'
                            || potherdetails.imdcode);

      IF p_weo_mot_policy_in.pol_type <> gv_LEXUS_pol_type THEN
         IF potherdetails.imdcode IS NOT NULL AND potherdetails.imdcode <> 0 THEN
            SELECT COUNT (*)
            INTO   v_cnt
            FROM   bjaz_intermediary
            WHERE  intermediary_id = potherdetails.imdcode;

            IF v_cnt = 0 THEN
               addinerrlist (   'Invalid Intermediary Code '
                             || potherdetails.imdcode
                             || '. Pls. check');
               COMMIT;
               save_error_code (mot_extra_cover.covernote_no, 1,
                                   'Invalid Intermediary Code '
                                || potherdetails.imdcode
                                || '. Pls. check');
--ABHI_ERROR_MSG.abhi_error_log('BJAZ_LEXUS_WEBSERVICE.ISSUE_MOTOR_POLICY 4137');
               RETURN;
            ELSE
               IF mot_extra_cover.sub_imdcode IS NOT NULL
                  AND mot_extra_cover.sub_imdcode <> '0' THEN
                  SELECT COUNT (*)
                  INTO   v_cnt
                  FROM   bjaz_subimd_master
                  WHERE  intermediary_id = potherdetails.imdcode
                         AND subimd_id = mot_extra_cover.sub_imdcode;

                  IF v_cnt = 0 THEN
                     addinerrlist (   'The Sub ImdCode '
                                   || mot_extra_cover.sub_imdcode
                                   || ' is Not registered with ImdCode '
                                   || potherdetails.imdcode
                                   || '. Pls. check.');
                     COMMIT;
                     save_error_code (mot_extra_cover.covernote_no, 1,
                                         'The Sub ImdCode '
                                      || mot_extra_cover.sub_imdcode
                                      || ' is Not registered with ImdCode '
                                      || potherdetails.imdcode
                                      || '. Pls. check.');
--ABHI_ERROR_MSG.abhi_error_log('BJAZ_LEXUS_WEBSERVICE.ISSUE_MOTOR_POLICY 4161');
                     RETURN;
                  END IF;
               END IF;
            END IF;
         END IF;

         DBMS_OUTPUT.put_line ('ISSUE MOTO POLICY --> 9' || p_error_code);
         v_cnt := 0;
         DBMS_OUTPUT.put_line ('1 v_cnt >>' || v_cnt);

         IF mot_extra_cover.covernote_no IS NOT NULL
            AND mot_extra_cover.covernote_no <> 0 THEN
            SELECT COUNT (*)
            INTO   v_cnt
            FROM   bjaz_covernote_status
            WHERE  covernote_no = mot_extra_cover.covernote_no AND ROWNUM < 2;

            IF v_cnt = 0 THEN
               addinerrlist (   'Invalid Covernote - '
                             || mot_extra_cover.covernote_no
                             || '. Pls. check.');
               COMMIT;
               save_error_code (mot_extra_cover.covernote_no, 1,
                                   'Invalid Covernote - '
                                || mot_extra_cover.covernote_no
                                || '. Pls. check.');
--ABHI_ERROR_MSG.abhi_error_log('BJAZ_LEXUS_WEBSERVICE.ISSUE_MOTOR_POLICY 4188');
               RETURN;
            ELSE
               SELECT intermediary_code
               INTO   v_imd
               FROM   bjaz_covernote_status
               WHERE  covernote_no = mot_extra_cover.covernote_no;

               IF v_imd <> '0' THEN
                  SELECT COUNT (*)
                  INTO   v_cnt
                  FROM   bjaz_covernote_status
                  WHERE  covernote_no = mot_extra_cover.covernote_no
                         AND intermediary_code = potherdetails.imdcode
                         AND ROWNUM < 2;

                  IF v_cnt = 0 THEN
                     addinerrlist
                          (   'This covernote is not registered for Imdcode '
                           || potherdetails.imdcode
                           || '. Pls. check.');
                     COMMIT;
                     save_error_code
                           (mot_extra_cover.covernote_no, 1,
                               'This covernote is not registered for Imdcode '
                            || potherdetails.imdcode
                            || '. Pls. check.');
--ABHI_ERROR_MSG.abhi_error_log('BJAZ_LEXUS_WEBSERVICE.ISSUE_MOTOR_POLICY 4215');
                     RETURN;
                  END IF;
               END IF;
            END IF;
         END IF;
      END IF;

      DBMS_OUTPUT.put_line ('2 v_cnt >>' || v_cnt);
      DBMS_OUTPUT.put_line ('p_rcpt_list>>' || p_rcpt_list.COUNT);
      DBMS_OUTPUT.put_line ('ISSUE MOTO POLICY --> 10' || p_error_code);
      v_cnt := 0;
      weo_mot_util.issue_b2c_motor_policy (puserid, p_rcpt_list,
                                           p_cust_details,
                                           p_weo_mot_policy_in,
                                           accessories_list, paddoncover_list,
                                           extra_cover_fields,
                                           premium_details,
                                           premium_summery_list, p_quest_list,
                                           pcontract_id, ppolicyissuedate,
                                           ppart_id, p_error, p_error_code,
                                           ppremiumpayerid, paymentmode,
                                           locationid, potherdetails.imdcode,
                                           NULL);
      DBMS_OUTPUT.put_line ('ISSUE MOTO POLICY --> 11' || p_error_code);
      DBMS_OUTPUT.put_line ('pcontract_id --> ' || pcontract_id);

      DBMS_OUTPUT.put_line ('p_error.COUNT () >>' || p_error.COUNT ());
      IF p_error.COUNT () > 0 THEN
         FOR i IN 1 .. p_error.COUNT () LOOP
            UPDATE bjaz_LEXUS_ws_data
            SET error_desc = error_desc || ' + ' || p_error (i).err_text
            WHERE  transactionid = BJAZ_LEXUS_WEBSERVICE.gv_LEXUS_polno;
         END LOOP;
--ABHI_ERROR_MSG.abhi_error_log('BJAZ_LEXUS_WEBSERVICE.ISSUE_MOTOR_POLICY 4247');
         RETURN;
      END IF;
      DBMS_OUTPUT.put_line ('ISSUE MOTO POLICY --> 11.1--> ' || p_error_code);

      DBMS_OUTPUT.put_line ('ISSUE MOTO POLICY --> 11.2' || pcontract_id);
      IF pcontract_id IS NULL THEN
         addinerrlist ('Contract Id is Null');
         save_error_code (mot_extra_cover.covernote_no, 1,
                          'Contract Id is Null');
         error_comments := 'CONTRACT ID RETURNED IS NULL';--changes for 57420986 - Proper Error message need to provide on interface/report
--ABHI_ERROR_MSG.abhi_error_log('BJAZ_LEXUS_WEBSERVICE.ISSUE_MOTOR_POLICY 4256');
         RETURN;
      END IF;

      DBMS_OUTPUT.put_line ('ISSUE MOTO POLICY --> 12' || p_error_code);

      BEGIN
         SELECT NVL (b.grosspremium, premium_details.final_premium), a.financercode
         INTO   v_nissan_premium ,  v_financercode
         FROM   bjaz_LEXUS_ws_data a join bjaz_lexus_ws_data_extn b
         on a.transactionid=b.transactionid
         WHERE  a.transactionid = potherdetails.covernote_no;

         IF v_nissan_premium < premium_details.final_premium THEN
            v_nissan_premium := v_hyundai_premium;
         ELSE
            v_nissan_premium := premium_details.final_premium;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            v_nissan_premium := premium_details.final_premium;
      END;

      DBMS_OUTPUT.put_line ('ISSUE MOTO POLICY --> 13' || p_error_code);

        IF NVL(bjaz_utils.get_param_value ('NTUNFCONF', v_financercode,
                                                               0,
                                                               TRUNC (SYSDATE)),
                                   0) = 1 THEN
         BEGIN
            SELECT imd_code
            INTO   v_nf_imd_code
            FROM   bjaz_packpol_agent_validations
            WHERE  user_level = 'LEXUS_NF_IMD' AND top_indicator = 'Y';
         EXCEPTION
            WHEN OTHERS THEN
               v_nf_imd_code := NULL;
         END;
      ELSE
         v_nf_imd_code := potherdetails.imdcode;
      END IF;


      IF p_instrument_type = 'AGNFLOAT' THEN
         v_event := bjaz_acc_utils.get_pay_event ('4');
         v_return :=
            bjaz_acc_utils.insert_receipts ('T', NULL, 1, p_scrutiny_no, '4',
                                            v_event, 1,
                                            potherdetails.imdcode,
                                            p_cust_details.part_id,
                                            potherdetails.imdcode, NULL,
                                            'LEXUS', v_instrument_no,
                                            v_instrument_date, 'S',
                                            pme_api.opus_date, v_bank_name,
                                            v_bank_branch_code,
                                            p_weo_mot_policy_in.branch_code,
                                            premium_details.final_premium,
                                            v_batch_id, NULL, NULL, NULL,
                                            NULL, NULL, NULL, NULL, NULL,
                                            pcontract_id, v_local_cheque_yn);
      ELSIF NVL (v_flt_type, 'NA') = 'NF' THEN
         v_event := bjaz_acc_utils.get_pay_event ('4');
         v_return :=
            bjaz_acc_utils.insert_receipts
                                        ('T', 'NF', 1,
                                         p_scrutiny_no /* scrytiny No Tagg */,
                                         '4', v_event, 1,
                                         v_nf_imd_code,--potherdetails.imdcode,
                                         p_cust_details.part_id,
                                         potherdetails.imdcode, NULL,
                                         'LEXUS', NULL,
                                         -- v_instrument_no,
                                         v_instrument_date, 'S',
                                         pme_api.opus_date, v_bank_name,
                                         v_bank_branch_code,
                                         p_weo_mot_policy_in.branch_code,
                                         v_hyundai_premium,
                                         --premium_details.final_premium,
                                         v_batch_id, NULL, NULL, NULL, NULL,
                                         NULL, NULL, NULL, NULL,
                                         pcontract_id, v_local_cheque_yn, 0,
                                         p_scrutiny_no, 'UNBLOCK', NULL,
                                         NULL, NULL, NULL,
                                         'NISSAN-BJAZ_NISSAN_UTILS');
      ELSE
         IF p_rcpt_list.COUNT = 0 THEN
            addinerrlist ('No Receipts found for this contract.');
            COMMIT;
            save_error_code (mot_extra_cover.covernote_no, 1,
                             'No Receipts found for this contract.');
--ABHI_ERROR_MSG.abhi_error_log('BJAZ_LEXUS_WEBSERVICE.ISSUE_MOTOR_POLICY 4346');
            RETURN;
         END IF;

         FOR i IN 1 .. p_rcpt_list.COUNT LOOP
            v_rcpt_obj := p_rcpt_list (i);

            BEGIN
               v_from_scrutiny :=
                       TO_NUMBER (NVL (TRIM (v_rcpt_obj.from_scrutiny), '0'));
            EXCEPTION
               WHEN OTHERS THEN
                  v_from_scrutiny := 0;
            END;
dbms_output.put_line('4362 v_rcpt_obj.receipt_no= '||v_rcpt_obj.receipt_no);
            SELECT instrument_no, instrument_date, bank_name,
                   bank_branch_code, type_of_receipt, local_cheque_yn
            INTO   v_instrument_no, v_instrument_date, v_bank_name,
                   v_bank_branch_code, v_type_of_receipt, v_local_cheque_yn
            FROM   bjaz_receipts
            WHERE  receipt_no = v_rcpt_obj.receipt_no AND collection_no = 1;

            IF v_type_of_receipt IN ('RMFLOAT', 'RMFLOATC', 'AGFLOAT') THEN
               v_pay_event := '4';
            ELSIF v_type_of_receipt IN ('CUSTFLT', 'REFPRMBK', 'TRNSPRMBK') THEN
               v_pay_event := '5';
            END IF;

            IF v_rcpt_obj.pay_mode = 1 THEN
               v_event := bjaz_acc_utils.get_pay_event (v_pay_event);
               v_return :=
                  bjaz_acc_utils.insert_receipts
                                            ('T', v_rcpt_obj.receipt_no, i,
                                             p_scrutiny_no, '1', v_event,
                                             NULL, potherdetails.imdcode,
                                             p_cust_details.part_id, NULL,
                                             NULL, 'LEXUS', NULL, NULL,
                                             NULL, pme_api.opus_date, NULL,
                                             NULL,
                                             p_weo_mot_policy_in.branch_code,
                                             v_rcpt_obj.pay_amt, v_batch_id,
                                             NULL, NULL, NULL, NULL, NULL,
                                             NULL, NULL, NULL, pcontract_id,
                                             NULL, 0, v_from_scrutiny,
                                             v_rcpt_obj.tag_status, NULL,
                                             NULL, NULL, NULL,
                                             v_rcpt_obj.remarks);

               IF v_return <> 0 THEN
                  p_error_code := 1;
                  save_error_code
                             (mot_extra_cover.covernote_no, 1,
                              'Exception while inserting receipts');--changes for 57420986 - Proper Error message need to provide on interface/report
                  p_error_code := 1;
--ABHI_ERROR_MSG.abhi_error_log('BJAZ_LEXUS_WEBSERVICE.ISSUE_MOTOR_POLICY 4400');
                  RETURN;
               END IF;
            ELSIF v_rcpt_obj.pay_mode = 2 THEN
               v_event := bjaz_acc_utils.get_pay_event (v_pay_event);

               IF v_type_of_receipt IN ('RMFLOAT', 'RMFLOATC', 'AGFLOAT') THEN
                  NULL;
               ELSIF v_type_of_receipt IN
                                         ('CUSTFLT', 'REFPRMBK', 'TRNSPRMBK') THEN
                  v_return :=
                     bjaz_acc_utils.insert_receipts
                                            ('T', v_rcpt_obj.receipt_no, i,
                                             p_scrutiny_no, v_pay_event,
                                             v_event, NULL,
                                             potherdetails.imdcode,
                                             p_cust_details.part_id,
                                             potherdetails.imdcode, NULL,
                                             'LEXUS', v_instrument_no,
                                             v_instrument_date, 'S',
                                             pme_api.opus_date, v_bank_name,
                                             v_bank_branch_code,
                                             p_weo_mot_policy_in.branch_code,
                                             v_rcpt_obj.pay_amt, v_batch_id,
                                             NULL, NULL, NULL, NULL, NULL,
                                             NULL, NULL, NULL, pcontract_id,
                                             v_local_cheque_yn, 0,
                                             v_from_scrutiny,
                                             v_rcpt_obj.tag_status, NULL,
                                             NULL, NULL, NULL,
                                             v_rcpt_obj.remarks);
               END IF;

               IF v_return <> 0 THEN
                  COMMIT;
                  save_error_code (mot_extra_cover.covernote_no, 1, '107');
                  p_error_code := 1;
--ABHI_ERROR_MSG.abhi_error_log('BJAZ_LEXUS_WEBSERVICE.ISSUE_MOTOR_POLICY 4437');
                  RETURN;
               END IF;
            END IF;
         END LOOP;
      END IF;

      DBMS_OUTPUT.put_line ('ISSUE MOTO POLICY --> 14' || p_error_code);
      DBMS_OUTPUT.put_line ('3 v_cnt >>' || v_cnt);

      IF p_weo_mot_policy_in.engine_no IS NULL
         AND p_weo_mot_policy_in.chassis_no IS NULL
         AND extra_cover_fields.covernote_no IS NOT NULL THEN
         UPDATE wip_policy_contracts
         SET conversion_status = 'C'
         WHERE  contract_id = pcontract_id;
      END IF;

      DBMS_OUTPUT.put_line ('4 v_cnt >>' || v_cnt);

      FOR i IN 1 .. paddoncover_list.COUNT LOOP
         IF paddoncover_list (i).param_ref IS NOT NULL
            AND paddoncover_list (i).param_ref = 'TPPD_RES' THEN
            UPDATE wip_policy_covers
            SET sum_insured_whole_cover = 6000
            WHERE  cover_code = 'TPPD' AND contract_id = pcontract_id;
         END IF;

         IF paddoncover_list (i).param_ref IN
               ('S3', 'S4', 'S17', 'S13', 'S14', 'T3', 'T4', 'T34', 'T37',
                'T33', 'S5', 'S6', 'S7', 'S12', 'S11') THEN
            IF p_weo_mot_policy_in.vehicle_type_code IN (22,43) THEN
               v_vehicle_type := 'P';
            ELSE
               v_vehicle_type := 'C';
            END IF;

            BEGIN
               SELECT sum_insured
               INTO   v_si
               FROM   bjaz_mibl_ws_addon_rate
               WHERE  vehicle_type_code =
                                         p_weo_mot_policy_in.vehicle_type_code
                      AND vehicle_class = v_vehicle_type
                      AND cover_code = paddoncover_list (i).param_ref
                      AND ROWNUM = 1
                      AND effective_date =
                            (SELECT MAX (effective_date)
                             FROM   bjaz_mibl_ws_addon_rate
                             WHERE  effective_date <=
                                           p_weo_mot_policy_in.term_start_date
                                    AND vehicle_type_code =
                                          p_weo_mot_policy_in.vehicle_type_code
                                    AND vehicle_class = v_vehicle_type
                                    AND cover_code =
                                                paddoncover_list (i).param_ref);
            EXCEPTION
               WHEN OTHERS THEN
                  v_si := 0;
            END;

            UPDATE wip_policy_covers
            SET sum_insured_whole_cover = v_si
            WHERE  cover_code = paddoncover_list (i).param_ref
                   AND contract_id = pcontract_id;
         END IF;
      END LOOP;

      BEGIN
         IF NVL (p_stax_dtls.tax_code, '0') <> '0' THEN
           -- bjaz_utils.save_stax_details (pcontract_id, p_stax_dtls);
           ba_motor_save.save_stax_details (pcontract_id, p_stax_dtls,
                                            p_stax_dtls_other_tp,
                                            p_stax_dtls_basic_tp);
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      DBMS_OUTPUT.put_line ('5 v_cnt >>' || v_cnt);

      UPDATE wip_bjaz_policy_bases_extn
      SET covernote_no = potherdetails.covernote_no,
          main_agent_code = potherdetails.imdcode,
          sub_agent_code = mot_extra_cover.sub_imdcode,
          prev_insurer_add = mot_extra_cover.extra_field1,
          term_start_time =
             (SELECT TO_TIMESTAMP ((   to_date(inspolicyeffectivedate,'MM/DD/YYYY')
                                    || ' '
                                    || inspolicyeffectivetime
                                   ),
                                   'DD-MON-RRRR hh24:mi:ss.ff3')
              FROM   bjaz_LEXUS_ws_data x
              WHERE  x.transactionid = potherdetails.covernote_no),
          ncb_rate = (p_weo_mot_policy_in.ncb * -1),
          comments = 'LEXUS',
       prev_insurer_name =
          NVL (prev_insurer_name,
               (SELECT previnsurcompanyname
                  FROM
                      bjaz_LEXUS_ws_data_extn x
                 WHERE x.transactionid = potherdetails.covernote_no))
      WHERE  contract_id = pcontract_id;

      DBMS_OUTPUT.put_line ('6 v_cnt >>' || v_cnt);

      IF p_weo_mot_policy_in.pol_type = gv_LEXUS_pol_type THEN
         BEGIN
            SELECT NVL (oddiscount, 0)
              INTO v_comm_desc
              FROM bjaz_lexus_ws_data_extn
             WHERE transactionid = potherdetails.covernote_no;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;

         UPDATE wip_bjaz_policy_bases_extn
            SET commercial_disc_rate = v_comm_desc
          WHERE contract_id = pcontract_id;

         /*IF v_oddiscount = 0 THEN
            BEGIN
               SELECT NVL (derived_comm_desc, 0)
               INTO   v_comm_desc
               FROM   bjaz_LEXUS_ws_data_extn
               WHERE  transactionid = potherdetails.covernote_no;
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;
         ELSE
            v_comm_desc := v_oddiscount;
         END IF;*/

         /*UPDATE wip_bjaz_policy_bases_extn
         SET commercial_disc_rate = v_comm_desc --new changes
     --    prev_insurer_name= p_weo_mot_policy_in.prv_ins_company  -- For Call 50738259 By Nitin. --50338052
         WHERE  contract_id = pcontract_id;*/

         BEGIN
            SELECT ROUND (od)
            INTO   v_comm_desc_amt
            FROM   bjaz_mibl_debug_tb
            WHERE  polno = potherdetails.covernote_no
                   AND tieup_name = 'LEXUS' AND param_ref = 'COMMDISC';
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         UPDATE wip_bjaz_policy_bases_extn
         SET commercial_disc_amt = v_comm_desc_amt
         WHERE  contract_id = pcontract_id;
      END IF;

     /* BEGIN--akshay
            SELECT ROUND(adjust_cd_ld_disc,2)
            INTO   v_adjust_cd_ld_disc
            FROM   bjaz_LEXUS_ws_data_extn
            WHERE  TRANSACTIONID = potherdetails.covernote_no;

         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;*/

         /*IF NVL(v_adjust_cd_ld_disc,0)>0 THEN

                UPDATE wip_bjaz_policy_bases_extn
                 SET ADD_LOAD_RATE = v_adjust_cd_ld_disc,
                 ADD_LOAD_REASON='N'
                 WHERE  contract_id = pcontract_id;

         ELSIF NVL(v_adjust_cd_ld_disc,0)<0 THEN

                    UPDATE wip_bjaz_policy_bases_extn
                     SET SPECIAL_DISC_RATE = v_adjust_cd_ld_disc
                     WHERE  contract_id = pcontract_id;

         END IF;*/


      DBMS_OUTPUT.put_line ('7 v_cnt >>' || v_cnt);

      SELECT COUNT (*)
      INTO   v_cnt
      FROM   bjaz_gen_uw_approvals
      WHERE  contract_id = pcontract_id AND status_flag = 'R' AND ROWNUM < 2;

      DBMS_OUTPUT.put_line ('8 v_cnt >>' || v_cnt);
      DBMS_OUTPUT.put_line ('8 v_cnt >>' || pcontract_id || 'pcontract_id');
      DBMS_OUTPUT.put_line ('8 v_cnt >>' || p_error_code || 'error_code');

      IF v_cnt = 0 THEN
         DBMS_OUTPUT.put_line ('9 v_cnt >>' || v_cnt);

         UPDATE wip_bjaz_mot_prem_summ_extn
         SET action_code = 'A'
         WHERE  contract_id = pcontract_id AND object_id IS NULL;

         bjaz_mov_routes.gv_error_message := NULL;

     BEGIN
            SELECT COUNT (1)
            INTO   v_1827_policy
            FROM   bjaz_mibl_debug_tb
            WHERE  polno = potherdetails.covernote_no AND param_ref = 'OD';
         EXCEPTION
            WHEN OTHERS THEN
               v_1827_policy := 0;
         END;

         BEGIN
            SELECT vehicleidv_year2, vehicleidv_year3
            INTO   v_vehicleidv2, v_vehicleidv3
            FROM   bjaz_LEXUS_ws_data
            WHERE  transactionid = potherdetails.covernote_no;
         EXCEPTION
            WHEN OTHERS THEN
               v_vehicleidv2 := 0;
               v_vehicleidv3 := 0;
         END;

         BEGIN
            SELECT vehicleidv
            INTO   v_vehicleidv
            FROM   bjaz_LEXUS_ws_data
            WHERE  transactionid = potherdetails.covernote_no;
         EXCEPTION
            WHEN OTHERS THEN
               v_vehicleidv := 0;
         END;

         IF v_1827_policy > 1 THEN
            DECLARE
               v_act   NUMBER;
               v_od    NUMBER;
            BEGIN
               FOR i IN (SELECT *
                         FROM   bjaz_mibl_debug_tb
                         WHERE  polno = potherdetails.covernote_no) LOOP
                  SELECT SUM (act)
                  INTO   v_act
                  FROM   bjaz_mibl_debug_tb
                  WHERE  param_ref = i.param_ref
                         AND polno = potherdetails.covernote_no;

                  SELECT SUM (od)
                  INTO   v_od
                  FROM   bjaz_mibl_debug_tb
                  WHERE  param_ref = i.param_ref
                         AND polno = potherdetails.covernote_no;

                  UPDATE wip_bjaz_mot_prem_summ_extn
                  SET act = v_act,
                      od = v_od
                  WHERE  param_ref = i.param_ref
                         AND contract_id = pcontract_id;

                  COMMIT;
               END LOOP;
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            UPDATE wip_bjaz_longterm_details
            SET sum_insured = v_vehicleidv
            WHERE  contract_id = pcontract_id AND YEAR = 1;

            UPDATE wip_bjaz_longterm_details
            SET sum_insured = v_vehicleidv2
            WHERE  contract_id = pcontract_id AND YEAR = 2;

            UPDATE wip_bjaz_longterm_details
            SET sum_insured = v_vehicleidv3
            WHERE  contract_id = pcontract_id AND YEAR = 3;

            COMMIT;
         END IF;

         IF p_weo_mot_policy_in.product_4digit_code =1870 THEN
             DECLARE
                l_prevpolicyno                  bjaz_LEXUS_ws_data_extn.prevpolicyno%TYPE;
                l_prevpolicyeffectivedate   bjaz_LEXUS_ws_data_extn.prevpolicyeffectivedate%TYPE;
                l_prevpolicyexpirydate       bjaz_LEXUS_ws_data_extn.prevpolicyeffectivedate%TYPE;
                l_instpeffectivedate          bjaz_LEXUS_ws_data_extn.instpeffectivedate%TYPE;
                l_instpexpirydate              bjaz_LEXUS_ws_data_extn.instpexpirydate%TYPE;
             BEGIN
                 BEGIN
                    SELECT prevpolicyno,
                           prevpolicyeffectivedate,
                           prevpolicyeffectivedate,
                           instpeffectivedate,
                           instpexpirydate
                      INTO l_prevpolicyno,
                           l_prevpolicyeffectivedate,
                           l_prevpolicyexpirydate,
                           l_instpeffectivedate,
                           l_instpexpirydate
                      FROM bjaz_LEXUS_ws_data_extn
                     WHERE transactionid = potherdetails.covernote_no;
                 EXCEPTION
                    WHEN OTHERS THEN
                       l_prevpolicyno:=NULL;
                       l_prevpolicyeffectivedate:=NULL;
                       l_prevpolicyexpirydate:=NULL;
                       l_instpeffectivedate:=NULL;
                       l_instpexpirydate:=NULL;
                 END;

                 UPDATE wip_bjaz_vehicle_extn
                   SET ods_prev_pol_start_date =
                          TO_CHAR (trunc(to_date(l_prevpolicyeffectivedate, 'MM/DD/YYYY HH24:MI:SS')), 'DD-MON-YYYY'),
                       tp_prev_ins_name = p_weo_mot_policy_in.prv_ins_company,
                       tp_prev_ins_policy_no = p_weo_mot_policy_in.prv_policy_ref,
                       tp_prev_pol_start_date=
                          TO_CHAR (trunc(to_date(l_instpeffectivedate, 'MM/DD/YYYY HH24:MI:SS')), 'DD-MON-YYYY'),
                       tp_prev_pol_exp_date  =
                          TO_CHAR (trunc(to_date(l_instpexpirydate, 'MM/DD/YYYY HH24:MI:SS')), 'DD-MON-YYYY')
                 WHERE contract_id = pcontract_id;

                UPDATE wip_bjaz_policy_bases_extn
                   SET prev_policy_expiry_date =
                          TO_CHAR (trunc(to_date(l_prevpolicyexpirydate, 'MM/DD/YYYY HH24:MI:SS')), 'DD-MON-YYYY')
                 WHERE contract_id = pcontract_id;

                COMMIT;
             EXCEPTION
                WHEN OTHERS
                THEN
                   NULL;
             END;
         END IF;

         BEGIN
            v_result := pme_public.wip_restore_sync (pcontract_id);
            DBMS_OUTPUT.put_line ('10 v_cnt v_result >>' || v_result);
         EXCEPTION
            WHEN OTHERS THEN
               IF NVL (bjaz_mov_routes.gv_error_message, 'X') <> 'X' THEN
                  addinerrlist (bjaz_mov_routes.gv_error_message);
               ELSE
                  addinerrlist
                            (   'Error while issuing policy for contract id '
                             || pcontract_id
                             || ' ' || bjaz_mov_routes.gv_error_message);    --For call 50738259 by nitin shrikant
               END IF;

               save_error_code (mot_extra_cover.covernote_no, 1,
                                   'Error while issuing policy for contract id '
								   || pcontract_id
                                || DBMS_UTILITY.format_error_stack
                                || DBMS_UTILITY.format_error_backtrace);--changes for 57420986 - Proper Error message need to provide on interface/report
               v_ret := bjaz_acc_general.clear_premium_payer (pcontract_id);
               COMMIT;
--ABHI_ERROR_MSG.abhi_error_log('BJAZ_LEXUS_WEBSERVICE.ISSUE_MOTOR_POLICY 4790');
               RETURN;
         END;

         IF NVL (bjaz_mov_routes.gv_error_message, 'X') <> 'X' THEN
            p_error_code := 1;
            error_comments :=
                bjaz_mov_routes.gv_error_message || 'Exception in mov routes';
            save_error_code (mot_extra_cover.covernote_no, p_error_code,
                             'abc' || error_comments);
--ABHI_ERROR_MSG.abhi_error_log('BJAZ_LEXUS_WEBSERVICE.ISSUE_MOTOR_POLICY 4800');
            RETURN;
         END IF;

         DBMS_OUTPUT.put_line (   '$$ v_result >>'
                               || v_result
                               || '---'
                               || pcontract_id);

         IF v_result = 0 THEN
            SELECT policy_ref
            INTO   ppolicyref
            FROM   ocp_policy_bases
            WHERE  contract_id = pcontract_id AND top_indicator = 'Y';

            IF NVL (v_flt_type, 'NA') = 'NF' THEN
               BEGIN
                  bjaz_mudrank_account.post_process_policy (ppolicyref,
                                                            pcontract_id,
                                                            'WEB');

                  SELECT main_agent_code, web_userid, gross_premium
                  INTO   lmainagentcode, v_user_name, v_gross_premium
                  FROM   bjaz_policy_bases_extn
                  WHERE  contract_id = pcontract_id;

                  bjaz_nf_utils.process_nf_trans_dtls (ppolicyref,
                                                       pcontract_id,
                                                       'NF_TRANS_RNW');
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;
            END IF;
         ELSE
            v_ret := bjaz_acc_general.clear_premium_payer (pcontract_id);
            addinerrlist  (   'Error while issuing policy for contract id '
                             || pcontract_id
                             || ' ' || bjaz_mov_routes.gv_error_message);    --For call 50738259 by nitin shrikant
            COMMIT;
            save_error_code (mot_extra_cover.covernote_no, 1,
                             'Error while issuing policy for contract id '
                  || ' ' || bjaz_mov_routes.gv_error_message);    --For call 50738259 by nitin shrikant
--ABHI_ERROR_MSG.abhi_error_log('BJAZ_LEXUS_WEBSERVICE.ISSUE_MOTOR_POLICY 4843');
            RETURN;
         END IF;
      ELSIF v_cnt > 0 THEN
         ppolicyref := pcontract_id;
      END IF;

      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         save_error_code (BJAZ_LEXUS_WEBSERVICE.gv_LEXUS_polno, 1,
                             'LEXUS '
                          || ' : EXCEPTION WHILE ISSUING MOTOR POLICY '	
                          || DBMS_UTILITY.format_error_stack
                          || DBMS_UTILITY.format_error_backtrace
              || ' ' || bjaz_mov_routes.gv_error_message);   --changes for 57420986 - Proper Error message need to provide on interface/report
			  --For call 50738259 by nitin shrikant
--ABHI_ERROR_MSG.abhi_error_log('BJAZ_LEXUS_WEBSERVICE.ISSUE_MOTOR_POLICY 4859');
         RETURN;
         DBMS_OUTPUT.put_line ('EXCEPTION >>' || SQLERRM);
   END issue_motor_policy;

   FUNCTION get_LEXUS_basic_od_prem
      RETURN NUMBER
   IS
   BEGIN
      RETURN gvx_LEXUS_vehicle_od;
   END get_LEXUS_basic_od_prem;

   PROCEDURE set_LEXUS_od_disc_percent (
      p_disc_percent   IN   NUMBER
   )
   IS
   BEGIN
      gv_LEXUS_od_disc_percent := p_disc_percent;
   END set_LEXUS_od_disc_percent;

   PROCEDURE get_report_dtls (
      p_integration_name         IN       VARCHAR2,
      p_loc_code                 IN       NUMBER,
      p_reports_pol_search_dtl   IN       weo_rec_strings20,
      p_LEXUS_pol_lst           OUT      bjaz_LEXUS_ws_lst,
      p_error                    OUT      weo_tyge_error_message_list,
      p_error_code               OUT      NUMBER
   )
   AS
      v_sql          VARCHAR2 (8000);
      v_sql_where    VARCHAR2 (4000)        := '';
      v_count        NUMBER (8);
      v_error        weo_tyge_error_message;
      v_sql_lexus    VARCHAR2 (8000)
         := 'SELECT bjaz_lexus_wS_obj(inspolicytype, inspolicyno, inspolicyissuingdealercode, inspolicycreateddate,
inspolicycreatedtime, inspolicyeffectivedate, inspolicyeffectivetime, inspolicyexpirydate, proposaldate,
proposaltime, proposertype, a.transactionid, salutation, firstname, middlename, lastname, companyname,
gender, dateofbirth, occupation, address1, address2, address3, citycode, statecode, pincode, email, 
vehicleclass, vehicleinvoicedate, vehiclemake, modelcode, variantcode, engineno, chassisno, cc,
yearofmanufacture, registrationno, rtocode, iscsd, vehicleexshowroomprice, vehicleexshowroomprice_year2, 
vehicleexshowroomprice_year3, vehicleidv, vehicleidv_year2, vehicleidv_year3, nonelectricaccexshowroom, 
nonelectricaccidv, nonelectricaccpremium, electricaccexshowroom, electricaccidv, electricaccpremium, 
bifuelkitvalue, bifuelkitidv, bifueltppremium, bifuelkitpremium, nonelectricaccidv2, 
nonelectricaccpremium2, electricaccidv2, electricaccpremium2, bifuelkitpremium2, bifuelkitidv2, 
nonelectricaccidv3, nonelectricaccpremium3, electricaccidv3, electricaccpremium3, bifuelkitpremium3, 
bifuelkitidv3, seatingcapacity, isbangladeshcovered, isbhutancovered, ismaldivescovered, isnepalcovered, 
ispakistancovered, issrilankacovered, geographicextnpremiumod, geographicextnpremiumtp, financercode, 
financerbranch, aggrementtype, compdeductibles, basicodp, basicodp_year2, basicodp_year3, 
voluntarydeductible, voluntarydisc, isaamembership, aamemno, aadiscamount, aaexpiryperiod, 
isantitheftattached, antitheftdiscamount, ncbflag, ncbper, ncbamount, addonnildepamt, 
addonperbelongingamt, addonkeylossamt, addonengineprotectamt, addontyrealloyamt, addonsportsequipmentamt, 
last_uploaddate, bjaz_loc_code, bjaz_partner_id, bjaz_premium, bjaz_receipt, bjaz_veh_code, bjazpolicyno, 
scrutiny_no, error_desc, error_code, processed, sportsequipementinvoice, addonconsumablesamt, addonrtiamt, 
rtiregistrationcharges, rtiroadtax, addonhighvaluepaamt, imt43premium, imt44premium, netodpremium, 
basictpl, exttppd, totaltp, cpacoverpremownerdriver, ispapaiddriver, pacoverprempaiddriver, 
pasuminsuredperperson, panoofperson, pacoverpremunnameddriver, patotalpremium, ';

      v_sql_lexus1   VARCHAR2 (8000)
         := 'isllpaiddriver, llpaiddrivpremium, isllotheremp, llotherempcount, llotheremppremium, isllunnamedpass, 
llunnamedpasscount, llunnamedpasspremium, totallegalliability, netliabilitypremiumb, totalpremium, 
imt23premium, servicetax, grosspremium, imtcode, proposerpaymentmode, reconciledchequeno, 
reconciledchequedate, reconciledchequebank, reconciledchequebranch, reconciledchequeamount, 
reconciledchequeissuedby, payinslipno, payinslipdate, prevpolicyno, firstissingdealercode, 
prevpolicyeffectivedate, prevpolicyexpirydate, previnsurcompanycode, previnsurcompanyname, 
previnsurcompanyadd, vehcileinspectiondate, vehcileinspectionagencycode, isprevpolcopysubmit, 
isncbcertificatesubmit, iscustomerundertakingsubmit, filegenerateddate, filegeneratedtime, pancardnumber, 
uniquerefnumber, breakincase, breakindays, imt12premium, imt36premium, imt38premium, 
paownerdvrnomsalutation, paownerdvrnomname, paownerdvrnomdob, paownerdvrnomgender, paownerdvrnomrelation, 
paownerdvrnomminorsalutation, paownerdvrnomminorname, paownerdvrnomminorrelation, packagename, oddiscount, 
oddiscount2, oddiscount3, revisedod1, revisedod2, revisedod3, revisedod_discount1, revisedod_discount2, 
revisedod_discount3, imt35premium, merchantkey, paymenttype, authcode, referenceid, vehiclepremium, 
buyerstatecode, sellerstatecode, buyergstin, igstpercentage, igstamount, sgstpercentage, sgstamount, 
cgstpercentage, cgstamount, utgstpercentage, utgstamount, invoicenumber, instpeffectivedate, 
instpeffectivetime, instpexpirydate, longtermpolicy, cstcpapreexist, iscpainclusion, cpawaiverreasoncode, 
cstcpapreexist_ic, cstcpapreexist_policynumber, cstcpapreexist_startdate, cstcpapreexist_enddate, 
iscpa_dl_exist, cst_dl_number, cpaeffectivedate, cpaeffectivetime, cpaexpirydate, cpa_current_tenure, 
cpa_previous_tenure, cpasuminsured, democarflag, keralacessamount, isstandaloneod, tp_policynumber, 
tp_insurancecompany, emicoverflag, emicoverpercentage, emicoverpremium, emicount, emiamount, 
date_of_incorporation, ckyc_flag, ckyc_number, ckyc_document_reference_number, batterycoverpremium, null, 
null, null, null, null, null, null, null, null, null, null, null, null, null, null
) FROM bjaz_lexus_ws_data a, bjaz_lexus_ws_data_extn b where a.TRANSACTIONID=b.TRANSACTIONID and ';

   BEGIN
      p_LEXUS_pol_lst := bjaz_LEXUS_ws_lst ();
      p_error := weo_tyge_error_message_list ();

      IF p_integration_name = 'LEXUS' THEN
begin  
         IF p_reports_pol_search_dtl.stringval3 IS NOT NULL THEN
            v_sql_where :=
                  ' a.transactionid = '
               || ''''
               || p_reports_pol_search_dtl.stringval3
               || '''';
         END IF;
exception
        when others then
        null;
        end;

begin
  
         IF p_reports_pol_search_dtl.stringval4 IS NOT NULL THEN
            IF p_reports_pol_search_dtl.stringval3 IS NOT NULL THEN
               v_sql_where :=
                     v_sql_where
                  || ' and  a.BJAZPOLICYNO = '
                  || ''''
                  || p_reports_pol_search_dtl.stringval4
                  || '''';
            ELSE
               v_sql_where :=
                     v_sql_where
                  || ' and a.BJAZPOLICYNO = '
                  || ''''
                  || p_reports_pol_search_dtl.stringval4
                  || '''';
            END IF;
         END IF;

exception
        when others then
        null;
        end;         
         
begin
 IF p_reports_pol_search_dtl.stringval6 IS NOT NULL
         THEN
            IF p_reports_pol_search_dtl.stringval6 > TRUNC (SYSDATE)
            THEN
               v_error :=
                  weo_tyge_error_message (
                     9999,
                     'bjaz_abibl_web_service',
                     NULL,
                     NULL,
                     'FUTURE DATE IS NOT ALLOWED (To Date).',
                     1);
               p_error.EXTEND;
               p_error (p_error.COUNT ()) := v_error;
               p_error_code := 1;
               RETURN;
            END IF;
         END IF;
exception
        when others then
        null;
        end;
         
        begin

IF p_reports_pol_search_dtl.stringval3 IS NULL
            AND p_reports_pol_search_dtl.stringval4 IS NULL THEN
            IF p_reports_pol_search_dtl.stringval2 IS NOT NULL
               AND p_reports_pol_search_dtl.stringval5 IS NOT NULL THEN
               IF p_reports_pol_search_dtl.stringval2 = 'POISSDT' THEN
                  v_sql_where :=
                        v_sql_where
                     || ' to_date(TRIM(a.inspolicycreateddate),'''||'mm/dd/yyyy'||''') BETWEEN '
                     || ''''
                     || TO_DATE (p_reports_pol_search_dtl.stringval5,
                                 'dd-mon-yyyy')
                     || ''''
                     || ' AND '
                     || ''''
                     || TO_DATE (p_reports_pol_search_dtl.stringval6,
                                 'dd-mon-yyyy')
                     || '''';
               END IF;

               IF p_reports_pol_search_dtl.stringval2 = 'RINCDT' THEN
                  v_sql_where :=
                        v_sql_where
                     || ' to_date(TRIM(a.Inspolicyeffectivedate),'''||'mm/dd/yyyy'||''') BETWEEN '
                     || ''''
                     || TO_DATE (p_reports_pol_search_dtl.stringval5,
                                 'dd-mon-yyyy')
                     || ''''
                     || ' AND '
                     || ''''
                     || TO_DATE (p_reports_pol_search_dtl.stringval6,
                                 'dd-mon-yyyy')
                     || '''';
               END IF;

               IF p_reports_pol_search_dtl.stringval2 = 'LASTUPDD' THEN
                  v_sql_where :=
                        v_sql_where
                     || ' to_date(TRIM(a.Last_Uploaddate),'''||'DD/MM/RRRR'||''') BETWEEN '
                     || ''''
                     || TO_DATE (p_reports_pol_search_dtl.stringval5,
                                 'dd-mon-YYYY')
                     || ''''
                     || ' AND '
                     || ''''
                     ||  TO_DATE (p_reports_pol_search_dtl.stringval6,
                                 'dd-mon-YYYY')
                     || '''';
               END IF;
            END IF;
         END IF;

exception
        when others then
        null;
        end;
begin
         IF p_reports_pol_search_dtl.stringval1 IS NOT NULL
            AND NVL (p_reports_pol_search_dtl.stringval1, 0) <> 0 THEN
            v_sql_where :=
                  v_sql_where
               || ' AND a.Bjaz_Loc_Code ='
               || p_reports_pol_search_dtl.stringval1;
         END IF;
exception
when others then
null;
end;

 begin
         IF p_reports_pol_search_dtl.stringval8 IS NOT NULL THEN
            v_sql_where :=
                  v_sql_where
               || ' AND a.Error_Code ='
               || p_reports_pol_search_dtl.stringval8;
         END IF;
exception
when others then
null;
end;

begin        
 IF p_reports_pol_search_dtl.stringval7 = 'POLICY ISSUED' THEN
            v_sql_where := v_sql_where || ' AND a.BJAZPOLICYNO IS NOT NULL';
         END IF;
exception
when others then
null;
end;

begin
         IF p_reports_pol_search_dtl.stringval7 = 'POLICY NOT ISSUED' THEN
            v_sql_where := v_sql_where || ' AND a.BJAZPOLICYNO IS NULL';
         END IF;
exception
when others then
null;
end;
      END IF;

      BEGIN
         EXECUTE IMMEDIATE v_sql_lexus || v_sql_lexus1 || v_sql_where
         BULK COLLECT INTO p_LEXUS_pol_lst;

         v_count := p_LEXUS_pol_lst.COUNT ();

         IF v_count = 0 THEN
            v_error :=
               weo_tyge_error_message
                          (9999, 'BJAZ_LEXUS_WEBSERVICE', NULL, NULL,
                           'NO RECORDS FOUND FOR THE GIVEN SEARCH CRITERIA.',
                           1);
            p_error.EXTEND;
            p_error (p_error.COUNT ()) := v_error;
            p_error_code := 1;
            RETURN;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            v_error :=
               weo_tyge_error_message
                    (9999, 'BJAZ_LEXUS_WEBSERVICE', NULL, NULL,
                        'NO RECORDS FOUND FOR THE GIVEN SEARCH CRITERIA **.',
                     1 );
            p_error.EXTEND;
            p_error (p_error.COUNT ()) := v_error;
            p_error_code := 1;
            RETURN;
      END;
   END get_report_dtls;

   PROCEDURE re_issue_policy (
      p_hscipono   IN   bjaz_dealer_data.polno%TYPE
   )
   AS
      v_receipt_no           bjaz_receipts.receipt_no%TYPE;
      v_trans_amount         bjaz_receipts.trans_amount%TYPE;
      v_debit_bank_account   bjaz_receipts.debit_bank_account%TYPE;
      v_64vb_cnt             NUMBER;
      v_chk_bounced_cnt      NUMBER;
      v_rcpt_policy_exist    NUMBER;
      v_run_proc_flag        NUMBER;
      v_receipt_req_id       bjaz_receipts.receipt_req_id%TYPE;
      v_pol_issued_cnt       NUMBER;
      v_bjazpolicyno         VARCHAR2 (100);
      v_receipt_req_id_new   VARCHAR2 (100);
      v_bjaz_receipt         VARCHAR2 (100);
      v_cheque_status_new    VARCHAR2 (10);
   BEGIN
      SELECT NVL (param_value, 0)
      INTO   v_run_proc_flag
      FROM   bjaz_gen_param_master
      WHERE  param_ref = 'DEALERFAIL';

      BEGIN
         SELECT bjazpolicyno, bjaz_receipt
         INTO   v_bjazpolicyno, v_bjaz_receipt
         FROM   bjaz_LEXUS_ws_data
         WHERE  transactionid = p_hscipono;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      BEGIN
         SELECT receipt_req_id
         INTO   v_receipt_req_id_new
         FROM   bjaz_receipts
         WHERE  receipt_no = v_bjaz_receipt;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      BEGIN
         SELECT cheque_status
         INTO   v_cheque_status_new
         FROM   bjaz_receipts
         WHERE  receipt_no = v_bjaz_receipt;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_bjazpolicyno IS NOT NULL
         AND NVL (v_receipt_req_id_new, 'X') <> 'CANCELLED'
     AND v_cheque_status_new <> 'B' THEN
         save_error_code
                        (p_hscipono, 1,
                            'Policy already issued with the covernote no is '
                         || p_hscipono
                         || '  policy number '
                         || v_bjazpolicyno);
         COMMIT;
         RETURN;
      END IF;

      BEGIN
         SELECT bjaz_receipt
         INTO   v_receipt_no
         FROM   bjaz_LEXUS_ws_data
         WHERE  transactionid = p_hscipono;
      EXCEPTION
         WHEN OTHERS THEN
            v_receipt_no := NULL;
      END;

      IF NVL (v_receipt_no, 'X') = 'X' THEN
         BEGIN
            SELECT bjaz_receipt
            INTO   v_receipt_no
            FROM   bjaz_mibl_ws_receipt_tb
            WHERE  polno = p_hscipono AND top_indicator = 'Y';
         EXCEPTION
            WHEN OTHERS THEN
               v_receipt_no := NULL;
         END;
      END IF;

      IF v_receipt_no IS NOT NULL THEN
         SELECT COUNT (*)
         INTO   v_pol_issued_cnt
         FROM   bjaz_temp_receipts a
         WHERE  receipt_no = v_receipt_no
                AND EXISTS (
                      SELECT 1
                      FROM   ocp_policy_versions
                      WHERE  contract_status <> 'O'
                             AND contract_id = a.contract_id);

         BEGIN
            SELECT COUNT (1)
            INTO   v_64vb_cnt
            FROM   bjaz_receipts b
            WHERE  b.cheque_status = 'C' AND b.receipt_no = v_receipt_no
                   AND receipt_req_id IS NULL;
         EXCEPTION
            WHEN OTHERS THEN
               v_64vb_cnt := 0;
         END;

         BEGIN
            SELECT COUNT (1)
            INTO   v_rcpt_policy_exist
            FROM   bjaz_LEXUS_ws_data
            WHERE  bjaz_receipt = v_receipt_no AND transactionid <> p_hscipono
                   AND bjazpolicyno IS NOT NULL;
         EXCEPTION
            WHEN OTHERS THEN
               v_rcpt_policy_exist := 0;
         END;

         BEGIN
            SELECT COUNT (1)
            INTO   v_chk_bounced_cnt
            FROM   bjaz_cheque_dishonour
            WHERE  receipt_no = v_receipt_no;
         EXCEPTION
            WHEN OTHERS THEN
               v_chk_bounced_cnt := 0;
         END;

         IF (v_64vb_cnt = 0 OR v_pol_issued_cnt = 0) AND v_chk_bounced_cnt = 0
            AND v_rcpt_policy_exist = 0 THEN
            BEGIN
               SELECT debit_bank_account, trans_amount, TRIM (receipt_req_id)
               INTO   v_debit_bank_account, v_trans_amount, v_receipt_req_id
               FROM   bjaz_receipts
               WHERE  receipt_no = v_receipt_no;

               IF v_receipt_req_id IS NULL AND v_pol_issued_cnt < 2 THEN
                  BJAZ_LEXUS_WEBSERVICE.process_cancel_rcpt
                                                        (v_receipt_no,
                                                         v_trans_amount,
                                                         v_debit_bank_account);
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            COMMIT;
         END IF;
      END IF;

      IF v_pol_issued_cnt > 0 OR v_chk_bounced_cnt > 0 THEN
         UPDATE bjaz_mibl_ws_receipt_tb
         SET polno =
                   'R_'
                || TO_CHAR (SYSDATE, 'DD/MM/YYYY HH24:MI:SS')
                || '_'
                || polno,
             top_indicator = 'N'
         WHERE  polno = p_hscipono AND top_indicator = 'Y'
                AND tieup_name = 'LEXUS';
      END IF;

      IF v_64vb_cnt = 0 OR v_64vb_cnt IS NULL THEN
         clear_policy (p_hscipono);
         upload_policy (p_hscipono, 'N', 'N', 'REISSUE');
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         save_error_code (p_hscipono, 1,
                          'EXCEPTION WHILE REISSUEING THE BAJAJ POLICY ');
         RETURN;
   END re_issue_policy;

   PROCEDURE process_cancel_rcpt (
      p_receipt_no           IN   bjaz_receipts.receipt_no%TYPE,
      p_trans_amount         IN   bjaz_receipts.trans_amount%TYPE,
      p_debit_bank_account   IN   bjaz_receipts.debit_bank_account%TYPE
   )
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      puser_name       VARCHAR2 (1000);
      plocation_code   VARCHAR2 (1000);
      prcpt_obj        bjaz_accr_rcpt_obj;
      pinstr_list      bjaz_accr_instr_obj_list;
      pcontrol_obj     bjaz_accr_control_obj;
      policy_list      bjaz_accr_view_policy_list;
      pamend_obj       bjaz_accr_amend_rcpt_obj;
      p_error          weo_tyge_error_message_list;
      p_error_code     NUMBER;
      v_rcptime     VARCHAR2(50);
      v_cnt          NUMBER;
   BEGIN
      pinstr_list := bjaz_accr_instr_obj_list ();
      policy_list := bjaz_accr_view_policy_list ();
      p_error := weo_tyge_error_message_list ();
      prcpt_obj :=
         bjaz_accr_rcpt_obj (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL, NULL);
      pcontrol_obj :=
         bjaz_accr_control_obj (NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                NULL, NULL, NULL, NULL, NULL);
      pamend_obj :=
         bjaz_accr_amend_rcpt_obj (NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                   NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                   NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                   NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                   NULL, NULL, NULL, NULL);
      puser_name := 'LEXUS_sys@bajajallianz.co.in';
      plocation_code := '1000';
      prcpt_obj.receipt_type := 'Customer Float';
      prcpt_obj.cancel_rcpt_reason := 'LEXUS POLICY CANCELLED';
      pcontrol_obj.receipt_no := p_receipt_no;
      pamend_obj.prev_ch_instr_amt := p_trans_amount;
      pinstr_list.EXTEND ();
      pinstr_list (1) :=
         bjaz_accr_instr_obj (NULL, 'CH', NULL, NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, p_debit_bank_account,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL);

        BEGIN

           SELECT param_desc
              INTO v_rcptime
              FROM bjaz_gen_param_master
             WHERE param_ref = 'RCPTTIME';

            SELECT COUNT (1)
              INTO v_cnt
              FROM bjaz_receipts
             WHERE     receipt_no = p_receipt_no
                    AND system_start_date >
                           SYSDATE - NUMTODSINTERVAL (v_rcptime, 'MINUTE');
         EXCEPTION
            WHEN OTHERS
            THEN
               v_cnt := 0;
         END;

      IF v_cnt = 0 THEN
      weo_accr_receipt_extn.cancel_actual_receipt (puser_name,
                                                   plocation_code, prcpt_obj,
                                                   pinstr_list, pcontrol_obj,
                                                   policy_list, pamend_obj,
                                                   p_error, p_error_code);
      END IF ;
      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END process_cancel_rcpt;

   PROCEDURE clear_policy (
      p_hscipono   IN   bjaz_dealer_data.polno%TYPE
   )
   AS
      v_bjaz_rcpt    VARCHAR2 (100);
      v_rcpt_reqid   VARCHAR2 (100);
   BEGIN
      UPDATE bjaz_policy_bases_extn
      SET covernote_no = covernote_no || '-CANCELLED'
      WHERE  covernote_no = p_hscipono;

      UPDATE wip_bjaz_policy_bases_extn
      SET covernote_no = covernote_no || '-CANCELLED'
      WHERE  covernote_no = p_hscipono;

      BEGIN

         <<block_13>>
         BEGIN
            SELECT bjaz_receipt
            INTO   v_bjaz_rcpt
            FROM   bjaz_mibl_ws_receipt_tb
            WHERE  polno = p_hscipono AND top_indicator = 'Y'
                   AND tieup_name = 'LEXUS';

            SELECT NVL (receipt_req_id, '0')
            INTO   v_rcpt_reqid
            FROM   bjaz_receipts
            WHERE  receipt_no = v_bjaz_rcpt;
         EXCEPTION
            WHEN OTHERS THEN
               v_bjaz_rcpt := NULL;
               v_rcpt_reqid := '0';
         END block_13;

         IF v_bjaz_rcpt IS NOT NULL THEN
            IF v_rcpt_reqid = 'CANCELLED' THEN
               UPDATE bjaz_mibl_ws_receipt_tb
               SET polno =
                         'R_'
                      || TO_CHAR (SYSDATE, 'DD/MM/YYYY HH24:MI:SS')
                      || '_'
                      || polno,
                   top_indicator = 'N'
               WHERE  polno = p_hscipono AND tieup_name = 'LEXUS';
            END IF;
         END IF;
      END;

      UPDATE bjaz_LEXUS_ws_data
      SET processed = 'N',
          bjaz_receipt = NULL,
          bjazpolicyno = NULL,
          bjaz_loc_code = NULL,
          bjaz_partner_id = NULL,
          bjaz_veh_code = NULL,
          bjaz_premium = NULL,
          --step_code = NULL,
          ERROR_CODE = NULL,
          ERROR_DESC=NULL
      WHERE  transactionid = p_hscipono;

      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         save_error_code (p_hscipono, 1, 'EXCEPTION WHILE CLEARING POLICY');--57420986 - Proper Error message need to provide on interface/report
         RETURN;
   END clear_policy;

   PROCEDURE bjaz_LEXUS_issue_policy (
      p_param   VARCHAR2 DEFAULT 'N'
   )
   AS
      v_count    NUMBER;
      v_letter   VARCHAR2 (1);
   BEGIN
      FOR i IN (SELECT a.*,b.reconciledchequeno
                FROM   bjaz_LEXUS_ws_data a join bjaz_lexus_ws_data_extn b
                on a.transactionid=b.transactionid
                WHERE  a.bjazpolicyno IS NULL
                       AND b.reconciledchequeno IS NOT NULL
                       AND b.reconciledchequedate IS NOT NULL
                       AND b.reconciledchequebank IS NOT NULL
                       AND b.reconciledchequebranch IS NOT NULL
                       AND b.reconciledchequeamount IS NOT NULL
                       AND b.reconciledchequeissuedby IS NOT NULL
                       AND b.payinslipno IS NOT NULL
                       AND b.payinslipdate IS NOT NULL
                       AND NVL (a.bjaz_receipt, 'X') <> 'NF'
                       AND a.processed = 'N') LOOP
         v_count := 65;


        IF NVL(bjaz_utils.get_param_value( 'CHQ_A_TOYO' ,18,0,SYSDATE),0)>0
         THEN
         FOR j IN (SELECT b.reconciledchequeno
                   FROM   bjaz_LEXUS_ws_data_extn b join bjaz_lexus_ws_data a
                   on a.transactionid=b.transactionid
                   WHERE  b.transactionid <> i.transactionid
                          AND b.reconciledchequeno = i.reconciledchequeno
                          AND b.reconciledchequeissuedby = 'D'
                          AND a.bjazpolicyno IS NULL) LOOP
            IF i.reconciledchequeno = j.reconciledchequeno THEN
               SELECT CHR (v_count)
               INTO   v_letter
               FROM   DUAL;

               UPDATE bjaz_LEXUS_ws_data_extn
               SET reconciledchequeno = v_letter || i.reconciledchequeno
               WHERE  transactionid = i.transactionid;

               COMMIT;
               v_count := v_count + 1;
            END IF;
         END LOOP;
       END IF;
         BJAZ_LEXUS_WEBSERVICE.upload_policy (i.transactionid);
         COMMIT;
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END bjaz_LEXUS_issue_policy;
   --below procedure added by akshay
   PROCEDURE upload_payment_data (
      pagentsobj      IN       weo_agents_obj,
      p_payment_lst   IN       weo_rec_strings20_list,
      p_error         OUT      weo_tyge_error_message_list
   )
   AS
      v_logs_data_exist        NUMBER;
      v_LEXUS_data_exist      NUMBER;
      v_dealer_policy_exist    NUMBER;
      v_payment_dtls           NUMBER;
     v_uniqueref_rcpt_exist   NUMBER;
      v_err_msg                VARCHAR2 (1)                         := 'N';
      v_bjaz_pol               bjaz_LEXUS_ws_data.bjazpolicyno%TYPE;
      v_remarks                bjaz_LEXUS_ws_data.error_desc%TYPE;
      v_pol_cnt                NUMBER;
      v_p_payment_cnt          NUMBER;
      v_reconchequeno          VARCHAR2 (20);
      v_error_flag             VARCHAR2 (10)                       := 'FALSE';
      v_count                  NUMBER;
   BEGIN
      p_error := NEW weo_tyge_error_message_list ();

      FOR i IN 1 .. p_payment_lst.COUNT LOOP
         v_err_msg := 'N';
         v_reconchequeno := TRIM (p_payment_lst (i).stringval2);
         v_error_flag := 'FALSE';


         IF pagentsobj.var2 = 'PAYMENT_REMARK' THEN
            IF (p_payment_lst (i).stringval1 IS NOT NULL
                AND p_payment_lst (i).stringval2 IS NOT NULL
               ) THEN
               BEGIN
                  SELECT COUNT (*)
                  INTO   v_LEXUS_data_exist
                  FROM   bjaz_LEXUS_ws_data
                  WHERE  transactionid = TRIM (p_payment_lst (i).stringval1);
                  /*IF v_LEXUS_data_exist = 0 THEN
                     SELECT COUNT (*)
                     INTO   v_dealer_data_exist
                     FROM   bjaz_mibl_ws_data
                     WHERE  visofnumber = TRIM (p_payment_lst (i).stringval1);
                  END IF;*/

                  IF v_LEXUS_data_exist = 0 AND v_err_msg != 'Y' THEN
                     p_error.EXTEND ();
                     p_error (p_error.COUNT) :=
                        weo_tyge_error_message
                                             (1000, 'UPLOAD_CANPOL_DATA',
                                              NULL, NULL,
                                              'Covernote no '
                                              || p_payment_lst (i).stringval1
                                              || ' is not valid',
                                              1);
                     v_err_msg := 'Y';
                  END IF;
                  IF v_LEXUS_data_exist > 0 THEN
                     BEGIN
                        SELECT NVL (b.RECONCILEDCHEQUEAMOUNT, 0),
                               NVL (a.bjazpolicyno, 'NA')
                        INTO   v_payment_dtls,
                               v_bjaz_pol
                        FROM   bjaz_LEXUS_ws_data_extn b join bjaz_lexus_ws_data a
                        on a.transactionid=b.transactionid
                        WHERE  a.transactionid = TRIM (p_payment_lst (i).stringval1);
                     EXCEPTION
                        WHEN OTHERS THEN
                           NULL;
                     END;

                     BEGIN
                        SELECT NVL (TRIM (error_desc), 'NA')
                        INTO   v_remarks
                        FROM   bjaz_LEXUS_ws_data
                        WHERE  transactionid = TRIM (p_payment_lst (i).stringval1);
                     EXCEPTION
                        WHEN OTHERS THEN
                           NULL;
                     END;
                     IF v_remarks <> 'NA' AND v_err_msg != 'Y' THEN
                        p_error.EXTEND ();
                        p_error (p_error.COUNT) :=
                           weo_tyge_error_message
                              (1000, 'UPLOAD_CANPOL_DATA', NULL, NULL,
                               'Remaks is already uploaded against covernote no '
                               || p_payment_lst (i).stringval1,
                               1);
                        v_err_msg := 'Y';
                     ELSIF v_bjaz_pol <> 'NA' AND v_err_msg != 'Y' THEN
                        p_error.EXTEND ();
                        p_error (p_error.COUNT) :=
                           weo_tyge_error_message
                                 (1000, 'UPLOAD_CANPOL_DATA', NULL, NULL,
                                  'Covernote no '
                                  || p_payment_lst (i).stringval1
                                  || ' is already converted into policy no '
                                  || v_bjaz_pol,
                                  1);
                        v_err_msg := 'Y';
                     ELSIF v_payment_dtls <> 0 AND v_err_msg != 'Y' THEN
                        p_error.EXTEND ();
                        p_error (p_error.COUNT) :=
                           weo_tyge_error_message
                              (1000, 'UPLOAD_CANPOL_DATA', NULL, NULL,
                               'Payment details are already uploaded for ['
                               || p_payment_lst (i).stringval1 || ']',
                               1);
                        v_err_msg := 'Y';
                     ELSIF v_err_msg != 'Y' THEN
                        /*UPDATE bjaz_LEXUS_ws_data_extn --pol_status pol_remarks remarks_date
                       SET remarks_date =
                                              TO_DATE (SYSDATE, 'DD-MON-RRRR'),
                            pol_remarks = TRIM (p_payment_lst (i).stringval2),
                            pol_status = 'C'
                        WHERE  transactionid = TRIM (p_payment_lst (i).stringval1);*/
                        /*v_count := SQL%ROWCOUNT;
                        IF v_count = 0 THEN
                           UPDATE bjaz_mibl_ws_data_extn
                          SET remark_upload_date =
                                              TO_DATE (SYSDATE, 'DD-MON-RRRR'),
                               remarks = TRIM (p_payment_lst (i).stringval2)
                           WHERE  visofnumber =
                                           TRIM (p_payment_lst (i).stringval1);
                        END IF;*/
                        p_error.EXTEND ();
                        p_error (p_error.COUNT) :=
                           weo_tyge_error_message
                                     (1000, 'UPLOAD_CANPOL_DATA', NULL, NULL,
                                      'Remarks updated successfully for ['
                                      || p_payment_lst (i).stringval1 || ']',
                                      0);
                     END IF;
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_error.EXTEND ();
                     p_error (p_error.COUNT) :=
                        weo_tyge_error_message
                                     (1000, 'UPLOAD_CANPOL_DATA', NULL, NULL,
                                      'Error While Uploading For ['
                                      || p_payment_lst (i).stringval1 || '#'
                                      || p_payment_lst (i).stringval2
                                      || '] [' || SQLERRM || ' '
                                      || DBMS_UTILITY.format_error_backtrace
                                      || ']',
                                     1);
               END;
            ELSE
               p_error.EXTEND ();
               p_error (p_error.COUNT) :=
                  weo_tyge_error_message
                              (1000, 'UPLOAD_CANPOL_DATA', NULL, NULL,
                               'Kindly check all payment details against'
                               || p_payment_lst (i).stringval1 || ']',
                               1);
            END IF;
          END IF;
       END LOOP;
   EXCEPTION
        WHEN OTHERS THEN
          NULL;
   END;

   PROCEDURE block_unblock_proposal (
      p_imd_code         IN OUT   VARCHAR2,
      p_sub_imd_code     IN       VARCHAR2,
      p_vehicle_class    IN       VARCHAR2,
      p_business_type    IN       VARCHAR2,
      p_gvw              IN       NUMBER,
      p_state            IN       VARCHAR2,
      p_variant_code     IN       NUMBER,
      p_fuel_type        IN       VARCHAR2,
      p_tie_up_name      IN       VARCHAR2,
      p_blk_unblk_flag   OUT      VARCHAR2
   )
   IS
      v_valid_cnt   NUMBER := 0;
   BEGIN
      p_blk_unblk_flag := 'N';

      IF NVL (p_imd_code, '0') = '0' THEN
         BEGIN
            SELECT TO_CHAR (broker_code)
            INTO   p_imd_code
            FROM   bjaz_nissan_broker_dtls
            WHERE  tieup_name = p_tie_up_name;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
               p_imd_code :='ALL';
         END;
      END IF;

      SELECT COUNT (*)
      INTO   v_valid_cnt
      FROM   bjaz_ntu_validation_config
      WHERE  imd_code = p_imd_code AND sub_imd_code = p_sub_imd_code
             AND vehicle_class = p_vehicle_class
             AND business_type = p_business_type
             AND p_gvw BETWEEN gvw_range_from AND gvw_range_to
             AND state = p_state AND variant_code = p_variant_code
             AND fuel_type = p_fuel_type AND tie_up_name = p_tie_up_name
         AND top_indicator = 'Y';

      IF v_valid_cnt > 0 THEN
         p_blk_unblk_flag := 'Y';
      ELSE
         p_blk_unblk_flag := 'N';
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
         p_blk_unblk_flag := 'N';
   END;

   PROCEDURE LEXUS_SCHEDULER
        as
      begin
        for i in (
          select a.* from
          bjaz_lexus_ws_data a,bjaz_lexus_ws_data_extn b
          where a.transactionid=b.transactionid
          and a.bjazpolicyno is null
          )
          loop
            begin
              bjaz_lexus_webservice.upload_policy(i.transactionid);
              commit;
            exception
              when others then
                null;
              end;
          end loop;
        exception
              when others then
                null;
        end lexus_scheduler;

END BJAZ_LEXUS_WEBSERVICE;
