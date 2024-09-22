import logging
import os
import azure.functions as func
from dotenv import load_dotenv


app = func.FunctionApp()
load_dotenv("config.env")


@app.function_name(name="AddName1")
@app.route(route="add_name", auth_level=func.AuthLevel.ANONYMOUS, methods=["POST"])
@app.queue_output(
    arg_name="msg", queue_name="outqueue", connection="AzureWebJobsStorage"
)
@app.cosmos_db_output(
    arg_name="outputDocument",
    database_name=os.environ["COSMOS_DATABASE"],
    container_name=os.environ["COSMOS_CONTAINER"],
    connection="CosmosDbConnectionSetting",
)
def add_name(
    req: func.HttpRequest,
    msg: func.Out[func.QueueMessage],
    outputDocument: func.Out[func.Document],
) -> func.HttpResponse:
    """azure basic function to test output"""
    logging.info("Python HTTP trigger function processed a request.")
    logging.info("Python Cosmos DB trigger function processed a request.")
    name = req.params.get("name")
    if not name:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            name = req_body.get("name")

    if name:
        outputDocument.set(func.Document.from_dict({"id": name}))
        msg.set(name)  # type: ignore
        return func.HttpResponse(f"Hello {name}!")
    else:
        return func.HttpResponse(
            "Please pass a name on the query string or in the request body",
            status_code=400,
        )


@app.function_name(name="NewVisitor")
@app.route(route="new_visitor", auth_level=func.AuthLevel.ANONYMOUS)
@app.cosmos_db_input(
    arg_name="inputDocument",
    database_name=os.environ["COSMOS_DATABASE"],
    container_name=os.environ["COSMOS_CONTAINER_COUNTER"],
    connection="CosmosDbConnectionSetting",
)
@app.cosmos_db_output(
    arg_name="outputDocument",
    database_name=os.environ["COSMOS_DATABASE"],
    container_name=os.environ["COSMOS_CONTAINER_COUNTER"],
    connection="CosmosDbConnectionSetting",
    create_if_not_exists=True,
    partition_key="id",
    container_throughput=500,
)
def new_visitor(
    req: func.HttpRequest,
    outputDocument: func.Out[func.Document],
    inputDocument: func.DocumentList,
) -> str:
    """
    req parameter is needed to exhaust declaration from function.json via @app.route.
    create_if_not_exists doesnt work even it is using connection string which shouldnt have
    any access control for operations on db. I will let it live here as maybe Ill find a fix one day
    """
    logging.info(
        "Python Cosmos DB trigger function processed a request from new_visitor function."
    )
    try:
        document = inputDocument[0]
        new_number = document.data["visitors"] + 1
    except IndexError:
        logging.info("Index out of range - creating id:0 record")
        new_number = 1
    outputDocument.set(func.Document.from_dict({"id": "0", "visitors": new_number}))
    return f"All time visitor number: {new_number}"
