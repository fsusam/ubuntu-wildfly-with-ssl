# Install wildfly on ubuntu with oracle java and ssl configuration

# Build image
docker build -t="ubuntu_wildfly_ssl:1.0" .

# Run image
docker run -d -p 443:443 ubuntu_wildfly_ssl:1.0

# Test endpoints
https://localhost/bulk/export/export_3GPP_2018-09-06T10-48-35-572_ad291f4a-a6f5-4779-b1a6-a84ea3c43820.zip
https://localhost/login
https://localhost/bulk/export/jobs/