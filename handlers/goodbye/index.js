const handler = async () => {
  return {
    statusCode: 200,
    body: 'Success from Goodbye Handler',
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Credentials': true,
    },
  };
};

module.exports = { handler };
