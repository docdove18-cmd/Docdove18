const express = require('express');
const http = require('http');
const { Server } = require('socket.io');

const app = express();
const server = http.createServer(app);
const io = new Server(server);

// --- Embedded Frontend HTML, CSS & JavaScript ---
app.get('/', (req, res) => {
    res.send(`
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Web Chat & Calls</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="bg-gray-100 h-screen flex items-center justify-center">

    <!-- Username Login Overlay -->
    <div id="login-modal" class="fixed inset-0 bg-black/70 z-50 flex items-center justify-center">
        <div class="bg-white p-6 rounded-lg shadow-xl w-80 text-center">
            <h2 class="text-xl font-bold text-gray-800 mb-4">Join Chat Room</h2>
            <input type="text" id="username-input" placeholder="Enter your name..." class="w-full px-4 py-2 border rounded-lg mb-4 text-sm focus:outline-none focus:ring-2 focus:ring-green-500">
            <button id="join-btn" class="w-full bg-green-600 text-white py-2 rounded-lg font-semibold hover:bg-green-700">Start Chatting</button>
        </div>
    </div>

    <!-- Main App Container -->
    <div class="flex w-full max-w-5xl h-[90vh] bg-white shadow-lg rounded-lg overflow-hidden relative">
        
        <!-- Sidebar -->
        <div class="w-1/3 border-r border-gray-200 flex flex-col bg-white">
            <div class="bg-gray-100 p-4 flex justify-between items-center border-b">
                <div class="flex items-center space-x-3">
                    <div class="w-10 h-10 rounded-full bg-green-500 text-white flex items-center justify-center font-bold" id="my-avatar">U</div>
                    <div>
                        <span class="font-semibold text-gray-800 text-sm block" id="my-display-name">User</span>
                        <span class="text-xs text-green-600">Online</span>
                    </div>
                </div>
            </div>
            
            <div class="p-3 bg-white border-b">
                <div class="flex items-center bg-gray-100 rounded-lg px-3 py-2 space-x-2">
                    <i class="fa-solid fa-users text-gray-400"></i>
                    <span class="text-xs font-semibold text-gray-600">Active Online Users</span>
                </div>
            </div>

            <!-- Online Users List -->
            <div id="users-list" class="overflow-y-auto flex-1 p-2 space-y-1">
                <!-- Dynamically populated -->
            </div>
        </div>

        <!-- Chat Area -->
        <div class="w-2/3 flex flex-col bg-[#efeae2]">
            <div class="bg-gray-100 px-4 py-3 flex justify-between items-center border-b">
                <div class="flex items-center space-x-3">
                    <div class="w-10 h-10 rounded-full bg-green-600 text-white flex items-center justify-center font-bold"><i class="fa-solid fa-globe"></i></div>
                    <div>
                        <h2 class="font-semibold text-gray-800 text-sm">Global Public Room</h2>
                        <span class="text-xs text-gray-500" id="room-status">Everyone can see and call here</span>
                    </div>
                </div>
                <div class="flex space-x-5 text-gray-600 text-lg">
                    <i class="fa-solid fa-video cursor-pointer hover:text-green-600" id="video-call-btn" title="Start Group Video Call"></i>
                    <i class="fa-solid fa-phone cursor-pointer hover:text-green-600" id="audio-call-btn" title="Start Group Audio Call"></i>
                </div>
            </div>

            <!-- Messages Box -->
            <div id="chat-messages" class="flex-1 p-4 overflow-y-auto space-y-3"></div>

            <!-- Message Input Footer -->
            <div class="bg-gray-100 px-4 py-3 flex items-center space-x-3">
                <input type="text" id="message-input" placeholder="Type a message..." class="flex-1 bg-white px-4 py-2 rounded-lg focus:outline-none text-sm">
                <button id="send-btn" class="bg-green-600 text-white px-4 py-2 rounded-lg text-sm font-semibold hover:bg-green-700"><i class="fa-solid fa-paper-plane"></i></button>
            </div>
        </div>
    </div>

    <!-- Call Overlay Modal -->
    <div id="call-modal" class="fixed inset-0 bg-black/80 z-50 hidden flex flex-col items-center justify-center">
        <div class="relative w-full max-w-3xl h-[70vh] bg-gray-900 rounded-lg overflow-hidden flex flex-col items-center justify-center shadow-2xl">
            <!-- Remote Video Stream -->
            <video id="remote-video" autoplay playsinline class="w-full h-full object-cover bg-black"></video>
            
            <!-- Local Video Stream Preview -->
            <video id="local-video" autoplay playsinline muted class="absolute top-4 right-4 w-32 h-24 object-cover rounded-lg border-2 border-white bg-gray-800 shadow-lg"></video>
            
            <!-- Status Text -->
            <div id="call-status" class="absolute top-4 left-4 text-white font-semibold bg-black/50 px-3 py-1 rounded text-xs">Calling Room...</div>

            <!-- Hang Up Control -->
            <div class="absolute bottom-6 flex space-x-6">
                <button id="hangup-btn" class="bg-red-600 text-white px-6 py-2 rounded-full font-bold shadow-lg hover:bg-red-700 text-sm"><i class="fa-solid fa-phone-slash"></i> End Call</button>
            </div>
        </div>
    </div>

    <!-- Socket.io Client & WebRTC Signaling -->
    <script src="/socket.io/socket.io.js"></script>
    <script>
        const socket = io();

        let myUsername = '';
        let localStream;
        let peerConnection;
        let isCalling = false;

        const iceServers = {
            iceServers: [{ urls: 'stun:stun.l.google.com:19302' }]
        };

        // Login Logic
        const loginModal = document.getElementById('login-modal');
        const usernameInput = document.getElementById('username-input');
        const joinBtn = document.getElementById('join-btn');

        joinBtn.addEventListener('click', () => {
            const name = usernameInput.value.trim();
            if (name) {
                myUsername = name;
                document.getElementById('my-display-name').innerText = myUsername;
                document.getElementById('my-avatar').innerText = myUsername.charAt(0).toUpperCase();
                loginModal.classList.add('hidden');
                socket.emit('join_room', myUsername);
            } else {
                alert('Please enter your name.');
            }
        });

        // Chat Message Logic
        const messageInput = document.getElementById('message-input');
        const sendBtn = document.getElementById('send-btn');
        const chatMessages = document.getElementById('chat-messages');

        sendBtn.addEventListener('click', sendMessage);
        messageInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') sendMessage();
        });

        function sendMessage() {
            const text = messageInput.value.trim();
            if (text) {
                socket.emit('chat_message', { text, sender: myUsername });
                messageInput.value = '';
            }
        }

        socket.on('chat_message', (data) => {
            const isMe = data.sender === myUsername;
            const div = document.createElement('div');
            div.className = \`flex \${isMe ? 'justify-end' : 'justify-start'}\`;
            div.innerHTML = \`
                <div class="\${isMe ? 'bg-green-100' : 'bg-white'} px-4 py-2 rounded-lg shadow max-w-xs text-sm">
                    <span class="block text-[10px] text-gray-500 font-bold">\${data.sender}</span>
                    <p class="text-gray-800">\${data.text}</p>
                </div>
            \`;
            chatMessages.appendChild(div);
            chatMessages.scrollTop = chatMessages.scrollHeight;
        });

        // Active Users List Update
        socket.on('update_users', (users) => {
            const usersList = document.getElementById('users-list');
            usersList.innerHTML = '';
            users.forEach(user => {
                const userDiv = document.createElement('div');
                userDiv.className = 'flex items-center px-3 py-2 hover:bg-gray-50 rounded-lg text-sm';
                userDiv.innerHTML = \`
                    <div class="w-8 h-8 rounded-full bg-gray-300 text-gray-700 flex items-center justify-center font-bold text-xs mr-3">\${user.charAt(0).toUpperCase()}</div>
                    <span class="text-gray-700 font-medium">\${user}</span>
                \`;
                usersList.appendChild(userDiv);
            });
        });

        // --- WebRTC Group Call Signaling ---
        document.getElementById('video-call-btn').addEventListener('click', () => startCall(true));
        document.getElementById('audio-call-btn').addEventListener('click', () => startCall(false));

        async function startCall(isVideo) {
            try {
                localStream = await navigator.mediaDevices.getUserMedia({ video: isVideo, audio: true });
                document.getElementById('local-video').srcObject = localStream;
                
                document.getElementById('call-modal').classList.remove('hidden');
                document.getElementById('call-status').innerText = 'Connecting call...';

                socket.emit('request_call', { sender: myUsername });
            } catch (err) {
                alert('Could not access camera/microphone permissions.');
            }
        }

        socket.on('incoming_call_request', async (data) => {
            if (data.sender !== myUsername && !isCalling) {
                const accept = confirm(\`\${data.sender} is starting a call. Join?\`);
                if (accept) {
                    isCalling.true;
                    localStream = await navigator.mediaDevices.getUserMedia({ video: true, audio: true });
                    document.getElementById('local-video').srcObject = localStream;
                    document.getElementById('call-modal').classList.remove('hidden');
                    document.getElementById('call-status').innerText = 'Connected';

                    createPeerConnection();
                    socket.emit('accept_call', { to: data.sender });
                }
            }
        });

        function createPeerConnection() {
            peerConnection = new RTCPeerConnection(iceServers);
            localStream.getTracks().forEach(track => peerConnection.addTrack(track, localStream));

            peerConnection.ontrack = (event) => {
                document.getElementById('remote-video').srcObject = event.streams[0];
            };

            peerConnection.onicecandidate = (event) => {
                if (event.candidate) {
                    socket.emit('ice_candidate', { candidate: event.candidate });
                }
            };
        }

        socket.on('start_peer_connection', async () => {
            createPeerConnection();
            const offer = await peerConnection.createOffer();
            await peerConnection.setLocalDescription(offer);
            socket.emit('offer', { offer });
        });

        socket.on('offer', async (data) => {
            if (!peerConnection) createPeerConnection();
            await peerConnection.setRemoteDescription(new RTCSessionDescription(data.offer));
            const answer = await peerConnection.createAnswer();
            await peerConnection.setLocalDescription(answer);
            socket.emit('answer', { answer });
        });

        socket.on('answer', async (data) => {
            await peerConnection.setRemoteDescription(new RTCSessionDescription(data.answer));
            document.getElementById('call-status').innerText = 'Connected';
        });

        socket.on('ice_candidate', async (data) => {
            if (peerConnection && data.candidate) {
                try {
                    await peerConnection.addIceCandidate(new RTCIceCandidate(data.candidate));
                } catch (e) { console.error(e); }
            }
        });

        document.getElementById('hangup-btn').addEventListener('click', closeCall);
        socket.on('end_call', closeCall);

        function closeCall() {
            if (peerConnection) peerConnection.close();
            if (localStream) localStream.getTracks().forEach(track => track.stop());
            peerConnection = null;
            localStream = null;
            isCalling = false;
            document.getElementById('call-modal').classList.add('hidden');
            document.getElementById('remote-video').srcObject = null;
            document.getElementById('local-video').srcObject = null;
            socket.emit('hangup');
        }
    </script>
</body>
</html>
    `);
});

// --- Server-Side Socket Management ---
let activeUsers = [];

io.on('connection', (socket) => {
    socket.on('join_room', (username) => {
        socket.username = username;
        activeUsers.push(username);
        io.emit('update_users', activeUsers);
    });

    socket.on('chat_message', (data) => {
        io.emit('chat_message', data);
    });

    socket.on('request_call', (data) => {
        io.emit('incoming_call_request', data);
    });

    socket.on('accept_call', () => {
        socket.broadcast.emit('start_peer_connection');
    });

    socket.on('offer', (data) => {
        socket.broadcast.emit('offer', data);
    });

    socket.on('answer', (data) => {
        socket.broadcast.emit('answer', data);
    });

    socket.on('ice_candidate', (data) => {
        socket.broadcast.emit('ice_candidate', data);
    });

    socket.on('hangup', () => {
        io.emit('end_call');
    });

    socket.on('disconnect', () => {
        if (socket.username) {
            activeUsers = activeUsers.filter(u => u !== socket.username);
            io.emit('update_users', activeUsers);
        }
    });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
