<Proxy balancer://mongrel_cluster3>
BalancerMember http://127.0.0.1:13000
BalancerMember http://127.0.0.1:13001
Order allow,deny
Allow from all
</Proxy> 

<VirtualHost *:80>
ServerAdmin naimu@handlino.com
ServerName chat.handlino.com
DocumentRoot /home/chatlino/current/public
ErrorLog /var/log/apache2/chatlino.com-error.log
CustomLog /var/log/apache2/chatlino.com-access.log combined
#ServerAlias chatlino.com *.chatlino.com

# Deflate
AddOutputFilterByType DEFLATE text/html text/xml text/plain text/css application/x-javascript text/javascript;
BrowserMatch ^Mozilla/4 gzip-only-text/html
BrowserMatch ^Mozilla/4\.0[678] no-gzip
BrowserMatch \bMSIE !no-gzip !gzip-only-text/html

    <Directory "/home/chatlino/current/public">
    Options FollowSymLinks 
    AllowOverride None 
    Order allow,deny 
    Allow from all 

    FileETag none
    ExpiresActive On
    ExpiresDefault "access plus 1 year"
    </Directory>

RewriteEngine On

# Check for maintenance file and redirect all requests 
RewriteCond %{DOCUMENT_ROOT}/system/maintenance.html -f
RewriteCond %{SCRIPT_FILENAME} !maintenance.html
RewriteRule ^.*$ /system/maintenance.html [L]

# Rewrite index to check for static 
RewriteRule ^/$ /index.html [QSA]

# Rewrite to check for Rails cached page 
RewriteRule ^([^.]+)$ $1.html [QSA]

# Redirect all non-static requests to cluster 
RewriteCond %{DOCUMENT_ROOT}/%{REQUEST_FILENAME} !-f
RewriteRule ^/(.*)$ balancer://mongrel_cluster3%{REQUEST_URI} [P,QSA,L]
</VirtualHost>