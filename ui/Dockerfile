FROM node:20-alpine
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install --omit=dev
COPY . .
USER node
EXPOSE 3000
ENTRYPOINT ["node"]
CMD [ "app.js" ]
