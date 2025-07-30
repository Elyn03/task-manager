import {
  DynamoDBDocumentClient,
  PutCommand,
  GetCommand,
  UpdateCommand,
  DeleteCommand,
  ScanCommand,
} from "@aws-sdk/lib-dynamodb";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";

const ddbClient = new DynamoDBClient({ region: "eu-west-1" });
const ddbDocClient = DynamoDBDocumentClient.from(ddbClient);

const tablename = "task-manager-apigateway";

export const handler = async (event) => {
  let body;

  try {
    body = typeof event.body === "string" ? JSON.parse(event.body) : event.body;
  } catch (err) {
    return {
      statusCode: 400,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: "Invalid JSON in request body",
        error: err.message,
      }),
    };
  }

  const operation = body?.operation;
  const payload = body?.payload || {};

  if (!operation) {
    return {
      statusCode: 400,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: "Bad request",
        error: "Missing 'operation' in request body",
      }),
    };
  }

  // Ajouter TableName seulement si payload existe et n'est pas vide
  if (operation !== "scan") {
    payload.TableName = tablename;
  }

  try {
    let response;

    switch (operation) {
      case "create":
        response = await ddbDocClient.send(new PutCommand(payload));
        break;
      case "read":
        response = await ddbDocClient.send(new GetCommand(payload));
        break;
      case "update":
        response = await ddbDocClient.send(new UpdateCommand(payload));
        break;
      case "delete":
        response = await ddbDocClient.send(new DeleteCommand(payload));
        break;
      case "scan":
        response = await ddbDocClient.send(
          new ScanCommand({ TableName: tablename })
        );
        break;
      case "echo":
        response = payload;
        break;
      default:
        return {
          statusCode: 400,
          headers: {
            "Access-Control-Allow-Origin": "*",
            "Content-Type": "application/json",
          },
          body: JSON.stringify({ message: `Unknown operation '${operation}'` }),
        };
    }

    return {
      statusCode: 200,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ message: "Success", data: response }),
    };
  } catch (err) {
    return {
      statusCode: 500,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: "Internal server error",
        error: err.message,
      }),
    };
  }
};
