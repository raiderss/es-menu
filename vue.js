const app = new Vue({
  el: '#app',
  data: {
    ui: false,
    selectedIndex: null,
    inputValue: '',
    showInput: false,
    inputLabel: '',
    inputPlaceholder: '',
    searchQuery: '',
    showBanList: false,
    showUnbanList: false,
    banList: [
      { identifier: 'steam:11000010000001', name: 'Player1', id: 1, reason: 'Cheating' },
      { identifier: 'steam:11000010000002', name: 'Player2', id: 2, reason: 'Toxic Behavior' },
      { identifier: 'steam:11000010000003', name: 'Player3', id: 3, reason: 'Griefing' },
      { identifier: 'steam:11000010000004', name: 'Player4', id: 4, reason: 'Exploiting' },
      { identifier: 'steam:11000010000005', name: 'Player5', id: 5, reason: 'Abuse' }
    ],
    unbanList: [
      { identifier: 'steam:11000010000006', name: 'Player6', id: 6 },
      { identifier: 'steam:11000010000007', name: 'Player7', id: 7 },
      { identifier: 'steam:11000010000008', name: 'Player8', id: 8 }
    ],
    isLightMode: localStorage.getItem('isLightMode') === 'true',
    panelWidth: 400,
    panelHeight: 300,
    panelTop: parseInt(localStorage.getItem('panelTop')) || 100,
    panelLeft: parseInt(localStorage.getItem('panelLeft')) || 100,
    isDragging: false,
    initialMouseX: 0,
    initialMouseY: 0,
    initialPanelX: 0,
    initialPanelY: 0,
    currentResolution: `${window.innerWidth}x${window.innerHeight}`,
    storedResolution: localStorage.getItem('screenResolution'),
    menuItems: [
      { name: 'Delete Nearby Objects', command: 'delete_objects' },
      { name: 'Delete Nearby Vehicles', command: 'delete_vehicles' },
      { name: 'Delete Nearby Peds', command: 'delete_peds' },
      { name: 'Ban Player by ID', command: 'ban_player', inputRequired: true, placeholder: 'Enter Player ID or Steam ID' },
      { name: 'Unban Player by ID', command: 'unban_player', inputRequired: true, placeholder: 'Enter Player ID or Steam ID' }
      // { name: 'Trigger Cheat Entity', command: 'cheat', inputRequired: true}

    ],
    player: {
      id: 1,
      name: 'PlayerOne',
      activePlayers: 150,
      money: 1000,
      bankBalance: 2500,
      cryptoBalance: 0.5,
      job: {
        name: 'Police Officer',
        label: 'Law Enforcement'
      },
      group: 'Admin'
    }
  },
  computed: {
    filteredBanList() {
      return this.banList.filter(player => {
        const searchQuery = this.searchQuery.toLowerCase();
        return player.login === false && (
          (player.name && player.name.toLowerCase().startsWith(searchQuery)) ||
          player.identifier.toLowerCase().startsWith(searchQuery)
        );
      });
    },
    filteredUnbanList() {
      return this.banList.filter(player => {
        const searchQuery = this.searchQuery.toLowerCase();
        return player.login === true && (
          (player.name && player.name.toLowerCase().startsWith(searchQuery)) ||
          player.identifier.toLowerCase().startsWith(searchQuery)
        );
      });
    }
  },
  created() {
    window.addEventListener('message', this.handleEventMessage);
    document.addEventListener("keydown", this.onKeydown);
  },
  mounted() {
    this.checkResolution();
    this.applyMode();
    const hasVisited = localStorage.getItem('hasVisitedEyestore');
    if (!hasVisited) {
      this.openUrl('https://eyestore.tebex.io');
      localStorage.setItem('hasVisitedEyestore', 'true');
    }
  },
  methods: {
    openUrl(url) {
      window.invokeNative("openUrl", url);
      window.open(url, '_blank');
    },

    handleEventMessage(event) {
      const item = event.data;
      switch (item.data) {
        case 'MENU':
          this.ui = item.open;
          this.banList = Array.isArray(item.banList) ? item.banList : [];  
          this.unbanList = Array.isArray(item.unbanList) ? item.unbanList : [];  
              if (item.info) {
                this.player = {
                  id: item.info.id || '',
                  name: item.info.name || 'Unknown', 
                  activePlayers: item.info.activePlayers || 0,
                  money: item.info.money || 0,
                  bankBalance: item.info.bankBalance || 0,
                  cryptoBalance: item.info.cryptoBalance || 0,
                  job: {
                    name: item.info.jobName || 'unemployed',
                    label: item.info.jobLabel || 'Civilian'
                  },
                  group: item.info.group || 'user'
                };
              } else {
                console.error("No player info found!");
              }
          break;
        case 'CLOSE':
          this.Close();
        break;
      }
    },       

    Close() {
      $.post(`https://${GetParentResourceName()}/Close`, JSON.stringify({}));
      this.ui = false;
    },

    onKeydown(event) {
      if (event.key === "Escape") {
        this.Close();
      }
    },

    moveToPosition(position) {
      switch (position) {
        case 'top-left':
          this.panelTop = 0;
          this.panelLeft = 0;
          break;
        case 'top-right':
          this.panelTop = 0;
          this.panelLeft = window.innerWidth - this.panelWidth;
          break;
        case 'bottom-left':
          this.panelTop = window.innerHeight - this.panelHeight;
          this.panelLeft = 0;
          break;
      }
      localStorage.setItem('panelTop', this.panelTop);
      localStorage.setItem('panelLeft', this.panelLeft);
    },

    checkResolution() {
      if (this.storedResolution !== this.currentResolution) {
        localStorage.removeItem('panelTop');
        localStorage.removeItem('panelLeft');
        this.panelTop = 100;
        this.panelLeft = 100;
        localStorage.setItem('screenResolution', this.currentResolution);
      }
    },
    toggleMode() {
      this.isLightMode = !this.isLightMode;
      localStorage.setItem('isLightMode', this.isLightMode);
      this.applyMode();
    },
    applyMode() {
      const menuContainer = document.querySelector('.menu-container');
      menuContainer.classList.toggle('light-mode', this.isLightMode);
      menuContainer.classList.toggle('dark-mode', !this.isLightMode);
    },
    selectItem(index) {
      this.selectedIndex = index;
      const selectedItem = this.menuItems[index];
      this.showInput = selectedItem.inputRequired || false;
      this.inputLabel = `Enter ID for ${selectedItem.name}`;
      this.inputPlaceholder = selectedItem.placeholder || '';
      this.executeCommand(selectedItem.command);
      this.showBanList = selectedItem.command === 'ban_player';
      this.showUnbanList = selectedItem.command === 'unban_player';
    },
    submitInput() {
      const selectedItem = this.menuItems[this.selectedIndex];
      if (this.inputValue) {
        this.executeCommand(`${selectedItem.command} ${this.inputValue}`);
        this.inputValue = '';
      } else {
        console.log('Please enter a valid ID.')
      }
    },
    executeCommand(command) {
      $.post(`https://${GetParentResourceName()}/Command`, JSON.stringify({
        action: command,
      }), (response) => {
        console.log('Command response:', response);
      })
      .fail((error) => {
        console.error('Failed to send command request:', error); 
      });
    },    
    togglePlayerStatus(player) {
      if (this.showBanList) {
        this.unbanPlayer(player);
      } else {
        this.banPlayer(player);
      }
    },
    banPlayer(player) {
      const unbanIndex = this.unbanList.findIndex(p => p.identifier === player.identifier);
      if (unbanIndex !== -1) {
        this.unbanList.splice(unbanIndex, 1);
        // console.log('Removed from unban list:', player.identifier);
      }
      const banIndex = this.banList.findIndex(p => p.identifier === player.identifier);
      if (banIndex !== -1) {
        this.banList[banIndex].login = false; 
        // console.log('Player already in ban list, login set to false:', player.identifier);
      } else {
        player.login = false; 
        this.banList.push(player); 
        // console.log('Added to ban list with login set to false:', player.identifier);
      }
      $.post(`https://${GetParentResourceName()}/Command`, JSON.stringify({
        action: 'banPlayer',
        player: player
      }), (response) => {
        if (response && Array.isArray(response.banList) && Array.isArray(response.unbanList)) {
          this.banList = response.banList;
          this.unbanList = response.unbanList;
        } else {
          console.error('Invalid response format from Lua:', response);
        }
      }).fail((error) => {
        console.error('Failed to send ban request:', error);
      });
    },
    
    unbanPlayer(player) {
      const banIndex = this.banList.findIndex(p => p.identifier === player.identifier);
      if (banIndex !== -1) {
        this.banList[banIndex].login = true; 
        console.log('Login status set to true for player:', player.identifier);
      } else {
        player.login = true;
        this.banList.push(player);
      }
      $.post(`https://${GetParentResourceName()}/Command`, JSON.stringify({
        action: 'unbanPlayer',
        player: player
      }), (response) => {
        if (response && Array.isArray(response.banList) && Array.isArray(response.unbanList)) {
          this.banList = response.banList;
          this.unbanList = response.unbanList;
        } else {
          console.error('Invalid response format from Lua:', response);
        }
      }).fail((error) => {
        console.error('Failed to send unban request:', error);
      });
    },    

    startDrag(event) {
      this.isDragging = true;
      this.initialMouseX = event.clientX;
      this.initialMouseY = event.clientY;
      this.initialPanelX = this.panelLeft;
      this.initialPanelY = this.panelTop;
      window.addEventListener('mousemove', this.updateDragPosition);
      window.addEventListener('mouseup', this.stopDrag);
    },
    updateDragPosition(event) {
      if (this.isDragging) {
        const deltaX = event.clientX - this.initialMouseX;
        const deltaY = event.clientY - this.initialMouseY;
        this.panelLeft = this.initialPanelX + deltaX;
        this.panelTop = this.initialPanelY + deltaY;
        localStorage.setItem('panelTop', this.panelTop);
        localStorage.setItem('panelLeft', this.panelLeft);
      }
    },
    stopDrag() {
      this.isDragging = false;
      window.removeEventListener('mousemove', this.updateDragPosition);
      window.removeEventListener('mouseup', this.stopDrag);
    },
    movePanel(event) {
      this.panelTop = event.clientY - 50;
      this.panelLeft = event.clientX - 200;
      localStorage.setItem('panelTop', this.panelTop);
      localStorage.setItem('panelLeft', this.panelLeft);
    }
  }
});