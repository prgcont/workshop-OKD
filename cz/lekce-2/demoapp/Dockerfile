from fedora

RUN yum install python-flask -y && yum clean all

COPY app.py /

ENV FLASK_APP=app.py

USER bin

EXPOSE 5000

CMD ["python", "-m", "flask", "run", "--host=0.0.0.0"]
