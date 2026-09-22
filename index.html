<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WhatsApp Web Clone - Direct P2P</title>
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- FontAwesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- PeerJS for Direct Browser-to-Browser Calls & Chat -->
    <script src="https://unpkg.com/peerjs@1.4.7/dist/peerjs.min.js"></script>
</head>
<body class="bg-gray-100 h-screen flex items-center justify-center">

    <!-- Main App Container -->
    <div class="flex w-full max-w-5xl h-[90vh] bg-white shadow-lg rounded-lg overflow-hidden relative">
        
        <!-- Sidebar -->
        <div class="w-1/3 border-r border-gray-200 flex flex-col bg-white">
            <div class="bg-gray-100 p-4 flex justify-between items-center border-b">
                <div class="flex items-center space-x-3">
                    <div class="w-10 h-10 rounded-full bg-green-500 text-white flex items-center justify-center font-bold">ME</div>
                    <span class="font-semibold text-gray-700 text-xs truncate max-w-[120px]" id="my-peer-id">Connecting...</span>
                </div>
            </div>
            <div class="p-3 bg-white border-b">
                <div class="flex items-center bg-gray-100 rounded-lg px-3 py-2 space-x-2">
                    <i class="fa-solid fa-search text-gray-400"></i>
                    <input type="text" id="target-id-input" placeholder="Paste Friend's ID here to connect" class="bg-transparent w-full focus:outline-none text-xs">
                </div>
                <button id="connect-btn" class="w-full mt-2 bg-green-600 text-white py-1.5 rounded text-xs font-semibold hover:bg-green-700">Connect to Friend</button>
            </div>
            <div class="overflow-y-auto flex-1 p-3">
                <p class="text-xs text-gray-500 leading-relaxed" id="connection-status">
                    <strong>Status:</strong> Waiting for connection...<br><br>
                    1. Share your ID (shown at top) with your friend.<br>
                    2. Paste their ID above and tap Connect.
                </p>
            </div>
        </div>

        <!-- Chat Area -->
        <div class="w-2/3 flex flex-col bg-[#efeae2]">
            <div class="bg-gray-100 px-4 py-3 flex justify-between items-center border-b">
                <div class="flex items-center space-x-3">
                    <div class="w-10 h-10 rounded-full bg-green-600 text-white flex items-center justify-center font-bold">W</div>
                    <div>
                        <h2 class="font-semibold text-gray-800 text-sm">WhatsApp Direct Chat</h2>
                        <span class="text-xs text-red-500" id="chat-online-status">Offline</span>
                    </div>
                </div>
                <div class="flex space-x-5 text-gray-600 text-lg">
                    <i class="fa-solid fa-video cursor-pointer hover:text-green-600" id="video-call-btn" title="Video Call"></i>
                    <i class="fa-solid fa-phone cursor-pointer hover:text-green-600" id="audio-call-btn" title="Audio Call"></i>
                </div>
            </div>

            <!-- Messages Box -->
            <div id="chat-messages" class="flex-1 p-4 overflow-y-auto space-y-3">
                <div class="text-center text-xs text-gray-400 my-2">Messages are peer-to-peer and encrypted between devices.</div>
            </div>

            <!-- Message Input Footer -->
            <div class="bg-gray-100 px-4 py-3 flex items-center space-x-3">
                <input type="text" id="message-input" placeholder="Type a message..." class="flex-1 bg-white px-4 py-2 rounded-lg focus:outline-none text-sm" disabled>
                <button id="send-btn" class="bg-green-600 text-white px-4 py-2 rounded-lg text-sm font-semibold hover:bg-green-700 opacity-50 cursor-not-allowed" disabled>Send</button>
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
            <div id="call-status" class="absolute top-4 left-4 text-white font-semibold bg-black/50 px-3 py-1 rounded text-xs">Calling...</div>

            <!-- Hang Up Control -->
            <div class="absolute bottom-6 flex space-x-6">
                <button id="hangup-btn" class="bg-red-600 text-white px-6 py-2 rounded-full font-bold shadow-lg hover:bg-red-700 text-sm"><i class="fa-solid fa-phone-slash"></i> End Call</button>
            </div>
        </div>
    </div>

    <!-- Script Logic -->
    <script>
        // Initialize PeerJS (Random public cloud server, zero configuration needed)
        const peer = new Peer();
        
        let conn = null;
        let localStream = null;
        let activeCall = null;

        const myPeerIdEl = document.getElementById('my-peer-id');
        const targetIdInput = document.getElementById('target-id-input');
        const connectBtn = document.getElementById('connect-btn');
        const connectionStatus = document.getElementById('connection-status');
        const chatOnlineStatus = document.getElementById('chat-online-status');
        const messageInput = document.getElementById('message-input');
        const sendBtn = document.getElementById('send-btn');
        const chatMessages = document.getElementById('chat-messages');

        peer.on('open', (id) => {
            myPeerIdEl.innerText = id;
            myPeerIdEl.title = id;
        });

        // Handle incoming connection requests from friends
        peer.on('connection', (connection) => {
            conn = connection;
            setupConnection();
            connectionStatus.innerHTML = `<strong>Status:</strong> Connected to peer!`;
        });

        // Connect button clicked
        connectBtn.addEventListener('click', () => {
            const friendId = targetIdInput.value.trim();
            if (!friendId) {
                alert('Please enter your friend\'s ID');
                return;
            }
            conn = peer.connect(friendId);
            setupConnection();
            connectionStatus.innerHTML = `<strong>Status:</strong> Connecting...`;
        });

        function setupConnection() {
            conn.on('open', () => {
                connectionStatus.innerHTML = `<strong>Status:</strong> Connected successfully! 🎉`;
                chatOnlineStatus.innerText = 'Online';
                chatOnlineStatus.className = 'text-xs text-green-600 font-semibold';
                messageInput.disabled = false;
                sendBtn.disabled = false;
                sendBtn.classList.remove('opacity-50', 'cursor-not-allowed');
            });

            conn.on('data', (data) => {
                appendMessage(data, 'incoming');
            });

            conn.on('close', () => {
                alert('Connection closed.');
                resetChatState();
            });
        }

        // Send Text Message
        sendBtn.addEventListener('click', sendMessage);
        messageInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') sendMessage();
        });

        function sendMessage() {
            const text = messageInput.value.trim();
            if (text && conn && conn.open) {
                conn.send(text);
                appendMessage(text, 'outgoing');
                messageInput.value = '';
            }
        }

        function appendMessage(text, type) {
            const isOutgoing = type === 'outgoing';
            const div = document.createElement('div');
            div.className = `flex ${isOutgoing ? 'justify-end' : 'justify-start'}`;
            div.innerHTML = `
                <div class="${isOutgoing ? 'bg-green-100' : 'bg-white'} px-4 py-2 rounded-lg shadow max-w-xs text-sm">
                    <p class="text-gray-800">${text}</p>
                </div>
            `;
            chatMessages.appendChild(div);
            chatMessages.scrollTop = chatMessages.scrollHeight;
        }

        function resetChatState() {
            chatOnlineStatus.innerText = 'Offline';
            chatOnlineStatus.className = 'text-xs text-red-500';
            messageInput.disabled = true;
            sendBtn.disabled = true;
            sendBtn.classList.add('opacity-50', 'cursor-not-allowed');
        }

        // --- Video & Audio Calling via PeerJS ---
        peer.on('call', async (call) => {
            const accept = confirm('Incoming call! Do you want to accept?');
            if (!accept) {
                call.close();
                return;
            }
            
            try {
                localStream = await navigator.mediaDevices.getUserMedia({ video: true, audio: true });
                document.getElementById('local-video').srcObject = localStream;
                
                call.answer(localStream);
                activeCall = call;
                showCallModal('Connected');

                call.on('stream', (remoteStream) => {
                    document.getElementById('remote-video').srcObject = remoteStream;
                });

                call.on('close', closeCallModal);
            } catch (err) {
                alert('Camera/Microphone permission denied.');
            }
        });

        document.getElementById('video-call-btn').addEventListener('click', () => initiateCall(true));
        document.getElementById('audio-call-btn').addEventListener('click', () => initiateCall(false));

        async function initiateCall(isVideo) {
            const friendId = targetIdInput.value.trim();
            if (!friendId) {
                alert('Please connect to a friend using their ID first.');
                return;
            }

            try {
                localStream = await navigator.mediaDevices.getUserMedia({ video: isVideo, audio: true });
                document.getElementById('local-video').srcObject = localStream;

                const call = peer.call(friendId, localStream);
                activeCall = call;
                showCallModal('Calling...');

                call.on('stream', (remoteStream) => {
                    document.getElementById('remote-video').srcObject = remoteStream;
                    document.getElementById('call-status').innerText = 'Connected';
                });

                call.on('close', closeCallModal);
            } catch (err) {
                alert('Could not access camera/microphone permissions.');
            }
        }

        function showCallModal(statusText) {
            document.getElementById('call-modal').classList.remove('hidden');
            document.getElementById('call-status').innerText = statusText;
        }

        document.getElementById('hangup-btn').addEventListener('click', () => {
            if (activeCall) activeCall.close();
            closeCallModal();
        });

        function closeCallModal() {
            if (localStream) {
                localStream.getTracks().forEach(track => track.stop());
                localStream = null;
            }
            document.getElementById('call-modal').classList.add('hidden');
            document.getElementById('remote-video').srcObject = null;
            document.getElementById('local-video').srcObject = null;
            activeCall = null;
        }
    </script>
</body>
</html>
