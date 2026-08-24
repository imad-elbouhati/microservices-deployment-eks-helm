FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt requirements.txt
RUN pip3 install --no-cache-dir -r requirements.txt \
    && useradd --system --create-home --uid 1000 appuser
COPY . .
USER appuser
EXPOSE 5000
ENTRYPOINT ["python3"]
CMD [ "/app/main.py" ]
