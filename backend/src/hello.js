exports.handler = async (event) => {
    return {
        statusCode: 200,
        headers: {
            'Content-Type': 'text/plain'
        },
        body: 'Hi'
    };
};