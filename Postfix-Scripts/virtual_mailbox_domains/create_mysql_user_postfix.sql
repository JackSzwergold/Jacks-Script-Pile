CONNECT mysql;
INSERT INTO user VALUES ('localhost','postfix','','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y');
UPDATE mysql.user SET password=PASSWORD("Yanggt!") WHERE user='postfix' AND host='localhost';
GRANT USAGE ON *.* TO 'postfix'@'localhost' IDENTIFIED BY PASSWORD '2fc879714f7d3e72';
GRANT SELECT ON mail.virtual_aliases TO 'postfix'@'localhost';
GRANT SELECT ON mail.virtual_users TO 'postfix'@'localhost';
GRANT SELECT ON mail.virtual_mailbox_domains TO 'postfix'@'localhost';
FLUSH PRIVILEGES;

