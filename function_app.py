import logging
import os
import azure.functions as func
from dotenv import load_dotenv


app = func.FunctionApp()
load_dotenv("config.env")


@app.function_name(name="AddName1")
@app.route(route="add_name", auth_level=func.AuthLevel.ANONYMOUS, methods=["POST"])
@app.queue_output(arg_name="msg", queue_name="outqueue", connection="AzureWebJobsStorage")
@app.cosmos_db_output(arg_name="outputDocument", database_name=os.environ["COSMOS_DATABASE"],
                      container_name=os.environ["COSMOS_CONTAINER"],
                      connection="CosmosDbConnectionSetting")
def add_name(req: func.HttpRequest, msg: func.Out[func.QueueMessage],
             outputDocument: func.Out[func.Document]) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')
    logging.info('Python Cosmos DB trigger function processed a request.')
    name = req.params.get('name')
    if not name:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            name = req_body.get('name')

    if name:
        outputDocument.set(func.Document.from_dict({"id": name}))
        msg.set(name)
        return func.HttpResponse(f"Hello {name}!")
    else:
        return func.HttpResponse(
                    "Please pass a name on the query string or in the request body",
                    status_code=400
                )
