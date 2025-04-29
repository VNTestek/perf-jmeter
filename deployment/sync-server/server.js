const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const morgan = require('morgan');
const winston = require('winston');
const fs = require('fs');
const path = require('path');
const { time } = require('console');

// Cấu hình logger
const logDir = 'logs';
if (!fs.existsSync(logDir)) {
    fs.mkdirSync(logDir);
}

const logger = winston.createLogger({
    level: 'info',
    format: winston.format.combine(
        winston.format.timestamp(),
        winston.format.json()
    ),
    transports: [
        new winston.transports.Console(),
        new winston.transports.File({ filename: path.join(logDir, 'sync-api.log') })
    ]
});

// Khởi tạo Express app
const app = express();
const port = process.env.PORT || 8089;

// Define constants
const UNKNOWN_STATUS = 'UNKNOWN';

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(morgan('combined'));

// Kho lưu trữ dữ liệu in-memory
const syncStore = {};
const commandStore = {};
const commandListStore = {};

// Định kỳ xóa dữ liệu cũ (older than 24 hours)
function cleanupOldData() {
    const now = Date.now();
    const oneDayMs = 24 * 60 * 60 * 1000;

    // Delete all data for the auth key
    for (const auth in syncStores) {
        if (syncStores[auth]) {
            syncStores[auth] = {};
        }
        if (commandStore[auth]) {
            commandStore[auth] = {};
        }
        logger.info(`Deleted all data for ${auth}`);
    }
}

// Clean all data 17h every day
// const cleanupTime = new Date();
// cleanupTime.setHours(17, 0, 0, 0); // 17h00
// const now = new Date();
// if (now > cleanupTime) {
//     cleanupTime.setDate(cleanupTime.getDate() + 1); // Nếu đã qua giờ cleanup thì cộng thêm 1 ngày
// }
// const timeToCleanup = cleanupTime.getTime() - now.getTime();
// setTimeout(() => {
//     cleanupOldData();
//     setInterval(cleanupOldData, 24 * 60 * 60 * 1000); // Cleanup every day
// }, timeToCleanup);

// // Middleware để kiểm tra auth key
// app.use((req, res, next) => {
//     const auth = req.query.auth;
//     if (authKeys && !authKeys.includes(auth)) {
//         return res.status(403).json({
//             success: false,
//             error: 'Unauthorized'
//         });
//     }
//     next();
// });

// Add list of auth keys and create a syncStore for each key
// VGVzdGVrX0FkbWlu: Base64 'Testek_Admin'
// VGVzdGVrX0REX1BlcmZvcm1hbmNlVGVzdA==: Base64 'Testek_DD_PerformanceTest'
const ADMIN_AUTH_KEY = 'VGVzdGVrX0FkbWlu';
const authKeys = [ADMIN_AUTH_KEY, 'VGVzdGVrX0REX1BlcmZvcm1hbmNlVGVzdA=='];
const syncStores = authKeys.reduce((acc, key) => {
    acc[key] = {};
    return acc;
}, {});

// Update worker status
app.post('/api/workerStatus', (req, res) => {
    const { auth } = req.query;
    if (!authKeys.includes(auth)) {
        return res.status(403).json({
            success: false,
            error: 'Unauthorized'
        });
    }

    const { workerId, executionId, status } = req.body;
    if (!workerId || !executionId || !status) {
        return res.status(400).json({
            success: false,
            error: 'Missing required parameters'
        });
    }

    const key = workerId.toLowerCase().trim();
    syncStores[auth][key] = {
        status: status,
        executionId: executionId,
        timestamp: Date.now()
    };
    logger.info('Worker status updated', {
        auth,
        executionId,
        status
    });
    // Update workder status of all workers to UNKNOWN
    syncStores[auth]['allWorkers'] = UNKNOWN_STATUS;

    res.json({
        success: true,
        key: key,
        status: syncStores[auth][key].status,
        allWorkers: syncStores[auth]['allWorkers']
    });
});

// Function check all workers status
function checkAllWorkersStatus(auth, executionId, expStatus) {
    const workers = Object.keys(syncStores[auth]);
    console.log('workers length: ', workers.length);
    //Show all workers status
    console.log('workers: ', workers);
    let isSameStatus = true;
    for (const worker of workers) {
        // skip for allWorkers
        if (worker === 'allWorkers') {
            continue;
        }
        const workerStatus = syncStores[auth][worker];
        console.log(`name: ${worker}, status: ${workerStatus.status}, executionId: ${workerStatus.executionId}`);
        if (workerStatus.status !== expStatus || workerStatus.executionId !== executionId) {
            isSameStatus = false;
            break;
        }
    }

    // Update allWorkers status
    let finalStatus = isSameStatus ? expStatus : UNKNOWN_STATUS;
    syncStores[auth]['allWorkers'] = finalStatus;

    // Show log of all workers
    console.log('All workers status: ', syncStores[auth]['allWorkers']);
    return { "status": syncStores[auth]['allWorkers'] };
}

// Get worker status
app.get('/api/workerStatus', (req, res) => {
    const { auth, workerId } = req.query;
    if (!auth || !workerId) {
        return res.status(400).json({
            success: false,
            error: 'Missing required parameters'
        });
    }
    if (!authKeys.includes(auth)) {
        return res.status(403).json({
            success: false,
            error: 'Unauthorized'
        });
    }
    const key = workerId.toLowerCase().trim();
    const workerStatus = syncStores[auth][key];
    if (!workerStatus) {
        return res.status(404).json({
            success: false,
            error: 'Worker not found'
        });
    }
    res.json({
        success: true,
        workerId: key,
        status: workerStatus.status,
        executionId: workerStatus.executionId,
        allWorkers: syncStores[auth]['allWorkers']
    });
});

//cleanup old data
app.delete('/api/cleanup', (req, res) => {
    const { auth, isAll } = req.query;
    if (!authKeys.includes(auth)) {
        return res.status(403).json({
            success: false,
            error: 'Unauthorized'
        });
    }
    // Delete all data for the auth key
    if (syncStores[auth]) {
        // Delete all data in auth key and keep the auth key
        syncStores[auth] = {};
        if (isAll) {
            // Delete all data in auth key and keep the auth key
            commandStore[auth] = {};
            commandListStore[auth] = {};
            syncStores[auth]['allWorkers'] = UNKNOWN_STATUS;
        }
        logger.info(`Deleted all data for ${auth}`);
    } else {
        return res.status(404).json({
            success: false,
            error: 'No data found for the provided auth key'
        });
    }

    res.json({
        success: true,
        message: 'Old data cleaned up'
    });
});

// Get all auth keys
app.get('/api/authKeys', (req, res) => {
    const { auth } = req.query;
    // Verify if auth = ADMIN_AUTH_KEY
    if (auth !== ADMIN_AUTH_KEY) {
        return res.status(403).json({
            success: false,
            error: 'Unauthorized'
        });
    }
    // Return all auth keys

    res.json({
        success: true,
        auths: authKeys,
        data: syncStores
    });
});

// Get status of all workers
app.get('/api/allWorkersStatus', (req, res) => {
    const { auth, status, index } = req.query;
    if (!authKeys.includes(auth)) {
        return res.status(403).json({
            success: false,
            error: 'Unauthorized'
        });
    }

    const workers = Object.keys(syncStores[auth]);
    let isSameStatus = true;
    for (let worker of workers) {
        console.log('workers length: ', workers.length);
        //Show all workers status
        console.log('workers: ', worker);
        // parse workerId to lower case
        const key = worker.toLowerCase().trim();
        // skip for allWorkers
        if (key === 'allworkers') {
            continue;
        }
        const workerStatuss = syncStores[auth][key];
        console.log(`name: ${worker}, status: ${workerStatuss.status}, executionId: ${workerStatuss.executionId}`);


        const workerStatus = syncStores[auth][worker];
        console.log(`name: ${worker}, status: ${workerStatus.status}, executionId: ${workerStatus.executionId}`);
        console.log(`Status: ${workerStatus.status}, expected ${status},  executionId: ${workerStatus.executionId} exe ${index}`);
        if (workerStatus.status !== status || workerStatus.executionId !== index) {
            isSameStatus = false;
            break;
        }
    }

    // Update allWorkers status
    console.log(`IS SAME STATUS: ${isSameStatus}`);
    console.log('workers length: ', workers.length);
    console.log("All workers status: ", syncStores[auth]['allWorkers']);
    // Update allWorkers status
    let finalStatus = isSameStatus & workers.length > 1 ? status : UNKNOWN_STATUS;
    syncStores[auth]['allWorkers'] = finalStatus;

    res.json({
        success: true,
        status: finalStatus
    });
});

// Get status of a specific worker
app.get('/api/specificWorkerStatus', (req, res) => {
    const { auth, workerId } = req.query;
    if (!authKeys.includes(auth)) {
        return res.status(403).json({
            success: false,
            error: 'Unauthorized'
        });
    }
    const key = workerId.toLowerCase().trim();
    const workerStatus = syncStores[auth][key];
    if (!workerStatus) {
        return res.status(404).json({
            success: false,
            error: 'Worker not found'
        });
    }
    res.json({
        success: true,
        workerId: key,
        executionId: workerStatus.executionId,
        status: workerStatus.status
    });
});

// Update command
app.post('/api/updateCommand', (req, res) => {
    const { auth } = req.query;
    if (!authKeys.includes(auth)) {
        return res.status(403).json({
            success: false,
            error: 'Unauthorized'
        });
    }

    const { command, index } = req.body;
    if (!command || !index) {
        return res.status(400).json({
            success: false,
            error: 'Missing required parameters'
        });
    }
    // Save command status for each auth key
    if (!commandStore[auth]) {
        commandStore[auth] = {};
    }

    // Update command status
    commandStore[auth] = {
        command: command.trim(),
        index: index,
        timestamp: Date.now()
    };

    logger.info('Command status updated', {
        index,
        command,
        timestamp: commandStore[auth].timestamp
    });

    res.json({
        success: true,
        command: commandStore[auth].command,
        index: commandStore[auth].index,
        timestamp: commandStore[auth].timestamp
    });
});

// Get command to execution
app.get('/api/getCommand', (req, res) => {
    const { auth, index } = req.query;
    if (!authKeys.includes(auth)) {
        return res.status(403).json({
            success: false,
            error: 'Unauthorized'
        });
    }
    if (!index) {
        return res.status(400).json({
            success: false,
            error: 'Missing required parameters'
        });
    }

    if (!commandListStore[auth] || !commandListStore[auth].commands) {
        return res.status(404).json({
            success: false,
            error: 'No command found for the provided auth key'
        });
    }

    // parse index to int
    const indexInt = parseInt(index);
    // Check if indexInt over the length of commandListStore[auth].commands send message OVERFLOW
    if (indexInt >= commandListStore[auth].commands.length) {
        res.send("echo INDEX_OUT_OF_BOUNDS");
        return;
    }

    // Get command from commandListStore with index
    const command = commandListStore[auth].commands[indexInt];
    if (!command) {
        return res.status(404).json({
            success: false,
            error: 'No command found for the provided auth key'
        });
    }
    // return String data
    res.send(command.trim());
});

// Save all command
app.post('/api/saveAllCommand', (req, res) => {
    const { auth } = req.query;
    if (!authKeys.includes(auth)) {
        return res.status(403).json({
            success: false,
            error: 'Unauthorized'
        });
    }

    const { commands } = req.body;
    if (!commands) {
        return res.status(400).json({
            success: false,
            error: 'Missing required parameters'
        });
    }
    // Save command status for each auth key
    if (!commandListStore[auth]) {
        commandListStore[auth] = {};
    }

    // Convert commands to list by |||    const commands = commands.split('|||');
    const commandList = commands.split('|||').slice(1);

    // Update command status
    commandListStore[auth] = {
        commands: commandList,
        timestamp: Date.now()
    };

    logger.info('Command status updated', {
        commands,
        timestamp: commandListStore[auth].timestamp
    });

    res.json({
        success: true,
        commands: commandListStore[auth].commands,
        timestamp: commandListStore[auth].timestamp
    });
});

// Get command list
app.get('/api/getCommandList', (req, res) => {
    const { auth } = req.query;
    if (!authKeys.includes(auth)) {
        return res.status(403).json({
            success: false,
            error: 'Unauthorized'
        });
    }
    if (!commandListStore[auth]) {
        return res.status(404).json({
            success: false,
            error: 'No command list found for the provided auth key'
        });
    }
    res.json({
        success: true,
        commands: commandListStore[auth].commands
    });
});

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({
        status: 'OK',
        uptime: process.uptime(),
        timestamp: Date.now()
    });
});

// Get all data (for debugging)
app.get('/api/debug/data', (req, res) => {
    const { auth } = req.query;
    if (!auth) {
        return res.status(400).json({
            success: false,
            error: 'Missing required parameters'
        });
    }
    if (!authKeys.includes(auth)) {
        return res.status(403).json({
            success: false,
            error: 'Unauthorized'
        });
    }
    res.json({
        success: true,
        data: syncStores[auth],
        commandStore: commandStore[auth],
        commandListStore: commandListStore[auth]
    });
});


// Khởi động server
app.listen(port, () => {
    logger.info(`Sync API server running at http://localhost:${port}`);
});
