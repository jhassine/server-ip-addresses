FROM alpine:3.12

RUN apk add --no-cache bash

COPY generate-csv.sh .

WORKDIR /app

CMD [ "/app/generate-csv.sh" ]