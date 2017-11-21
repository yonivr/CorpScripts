#quarantine_spoofed_protected_senders:
#Block reciving email from external sources like gmail with identical display names as in the organization

#ironport-il
quarantine_spoofed_protected_senders: if ((mail-from-dictionary-match("Protected_User_Names", 1)) OR (header-dictionary-match("Protected_User_Names","From", 1))) AND ((sendergroup != "WHITELIST") AND (sendergroup != "DLP") AND (sendergroup != "RELAYLIST") AND (sendergroup != "Authorized_888Holdings")) {
                                 quarantine("Ext_888Holdings_Spoof");
                             }
                             
quarantine_spoofed_protected_senders: if ((mail-from-dictionary-match("Protected_User_Names", 1)) OR (header-dictionary-match("Protected_User_Names","From", 1))) AND (sendergroup != "WHITELIST") AND (sendergroup != "DLP") AND (sendergroup != "RELAYLIST") AND (sendergroup != "Authorized_888Holdings") AND (mail-from-dictionary-match("Safe_Display_Name_Impersonators", 1)) {
notify-copy ("$EnvelopeSender", "", "", "Notification") ;                               
quarantine("Ext_888Holdings_Spoof");
                                         }


#ironport-lo
quarantine_spoofed_protected_senders: if ((mail-from-dictionary-match("Protected_User_Names", 1)) OR (header-dictionary-match("Protected_User_Names","From", 1))) AND ((sendergroup != "WHITELIST") AND (sendergroup != "RELAYLIST") AND (sendergroup != "Authorized_888Holdings")) {
                                 quarantine("Ext_888Holdings_Spoof");
                             }
