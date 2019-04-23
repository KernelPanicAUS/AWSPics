FROM python:3.7.3-alpine3.9

RUN apk add bash docker && \
    pip install awscli cfn-lint



