
secrets: . secrets.sh

users.admin.password ---> docker run authelia/authelia:latest authelia crypto hash generate argon2 --password 'admin'