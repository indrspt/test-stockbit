FROM nginx:alpine
COPY hello.txt /usr/share/nginx/html/
EXPOSE 80 443
