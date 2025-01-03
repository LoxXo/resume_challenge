import logging
import os
import azure.functions as func

# from dotenv import load_dotenv


app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)
# load_dotenv("config.env")


@app.function_name(name="new_visitor")
@app.route(route="new_visitor")
@app.cosmos_db_input(
    arg_name="inputDocument",
    database_name=os.environ["COSMOS_DATABASE"],
    container_name=os.environ["COSMOS_CONTAINER"],
    connection="CosmosDbConnectionSetting",
)
@app.cosmos_db_output(
    arg_name="outputDocument",
    database_name=os.environ["COSMOS_DATABASE"],
    container_name=os.environ["COSMOS_CONTAINER"],
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
    As for now setting new value works every time even when request is blocked etc.
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


@app.function_name(name="get_visitors")
@app.route(route="get_visitors")
@app.cosmos_db_input(
    arg_name="inputDocument",
    database_name=os.environ["COSMOS_DATABASE"],
    container_name=os.environ["COSMOS_CONTAINER"],
    connection="CosmosDbConnectionSetting",
)
def get_visitors(
    req: func.HttpRequest,
    inputDocument: func.DocumentList,
) -> str:
    logging.info(
        "Python Cosmos DB trigger function processed a request from get_visitor function."
    )
    try:
        document = inputDocument[0]
        visitor_number = document.data["visitors"]
        return f"Current visitor number: {visitor_number}"
    except IndexError as err:
        logging.info(f"Container is missing. {err}")
        return "Container in database is missing. Please create one."
