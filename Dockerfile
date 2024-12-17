# 使用官方 Node.js 映像（長期支援版本）
FROM node:18

# 設定工作目錄
WORKDIR /usr/src/app

# 複製 package.json 和 package-lock.json（如果存在）
COPY package*.json ./

# 安裝應用程式依賴
RUN npm install --production

# 複製所有專案檔案
COPY . .

# 暴露應用程式的埠號
EXPOSE 8080

# 啟動應用程式
CMD ["npm", "start"]
