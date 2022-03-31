import axios from "axios";

const DAPR_HOST = process.env.DAPR_HOST || "http://127.0.0.1";
const DAPR_HTTP_PORT = process.env.DAPR_HTTP_PORT || "3500";

async function main() {
  // Adding app id as part of the header
  sleep(180000);
  let axiosConfig = {
    headers: {
        "dapr-app-id": "order-processor"
    }
  };
  
  while (true) {
    const order = {orderId: Math.floor(Math.random() * 10000) };

    // Invoking a service
    const res = await axios.post(`${DAPR_HOST}:${DAPR_HTTP_PORT}/orders`, order , axiosConfig);
    console.log("Order passed: " + res.config.data);

    await sleep(1000);
  }
}

async function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

main().catch(e => console.error(e))