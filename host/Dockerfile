FROM ubuntu:latest

RUN sudo install bridge-utils uml-utilities

COPY . .

CMD ["gcc server.c -o server && ./server"]