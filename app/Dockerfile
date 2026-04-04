# base image
FROM node:14-alpine

# current working directory inside container
WORKDIR /code

# Install dependencies
COPY package.json .
RUN npm install
RUN npm install text-encoding

# Copy your app code
COPY . .

# Expose app port
EXPOSE 3000

# run application on 3000 port
CMD ["node", "index.js"]