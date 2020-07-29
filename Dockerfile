FROM alpine:3.12

RUN apk add --no-cache jq

COPY generate-csv.sh .

WORKDIR /app

CMD [ "/app/generate-csv.sh" ]