from flask import Flask
import os.path
app = Flask(__name__)

@app.route("/")
def hello():
    if os.path.exists('/volume/test'):
        return "Hello from pvc!"
    return "Hello World!"

if __name__ == "__main__":
    app.run()
    
