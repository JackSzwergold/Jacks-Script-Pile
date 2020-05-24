csvde -m -n -g -f "C:\export\example_com_recipients.txt" \
-r "(|(&(objectClass=user)(objectCategory=person)) \
(objectClass=groupOfNames) (objectClass=msExchDynamicDistributionList))" \
-l proxyAddresses
pscp -i example_com.ppk example_com_recients.txt e3k@172.16.1.1:/home/e3k/
