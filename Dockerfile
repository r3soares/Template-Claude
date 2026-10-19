FROM python:3.12-slim

RUN addgroup --system --gid 10001 app && adduser --system --uid 10001 --ingroup app app
WORKDIR /app
COPY --chown=10001:10001 src/ ./src/
USER 10001:10001

ENV PYTHONPATH=/app/src PORT=8080
EXPOSE 8080
CMD ["python", "-m", "app.server"]
