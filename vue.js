const app = new Vue({
  el: "#app",
  data: {
    nui: false,
    addspace: false,
    addspacee: false,
    disabledselection: false,
    disableddelete: false,
    Delete: false,
    characterInfo: false,
    translations:[],
    nationalities: [],
    gender: [
      "Male",
      "Female"
    ],
    onysubs: {},
    data: [
      {
        identifier: "1",
        level: 3,
        xp: 100,
        gender: "Male",
        nation: "Italy",
        age: 91,
        cash: 10000,
        bank: 1000,
        online: "13min",
        name: "Wizard Sarsılmaz"
      },
      {
        identifier: "2",
        level: 3,
        xp: 33,
        gender: "Male",
        nation: "Italy",
        age: 91,
        cash: 10000,
        bank: 1000,
        online: "13min",
        name: "Seda Sarsılmaz"
      },
      {
        identifier: "3",
        level: 3,
        xp: 33,
        gender: "Male",
        nation: "Italy",
        age: 91,
        cash: 10000,
        bank: 1000,
        online: "13min",
        name: "Tuna Sarsılmaz"
      },
      {
        identifier: "4",
        level: 3,
        xp: 33,
        gender: "Male",
        nation: "Italy",
        age: 91,
        cash: 10000,
        bank: 1000,
        online: "13min",
        name: "Wizard Sarsılmaz"
      },
      {
        identifier: "5",
        level: 3,
        xp: 33,
        gender: "Male",
        nation: "Italy",
        age: 91,
        cash: 10000,
        bank: 1000,
        online: "13min",
        name: "Wizard Sarsılmaz"
      },
      

    ],
    CharacterCreatorInput: {
      firstname: "",
      lastname: "",
      nation: "Nation",
      gender: "Gender",
      birthdate: ""
    },
    select: 0,
    
  },

  methods: {
    async fetchData() {
      const response = await fetch('https://countriesnow.space/api/v0.1/countries/');
      if(response){
        const data = await response.json();
        const result = data.data;
          
        result.forEach(obj => {
          this.nationalities.push(obj.country);
        });
      }
    },
    CreateCharacter() {
      if (this.CharacterCreatorInput.firstname !== "") {
        if (this.CharacterCreatorInput.lastname !== "") {
          if (this.CharacterCreatorInput.nation !== "Nation") {
            if (this.CharacterCreatorInput.gender !== "Gender") {
              if (this.CharacterCreatorInput.birthdate !== "") {
                axios.post(`https://${GetParentResourceName()}/CreateCharacter`, {
                 data: this.CharacterCreatorInput
                });
              } else {
                axios.post(`https://${GetParentResourceName()}/Notification`, {
                  type: "error",
                  msg: "Enter your Date of Birth correctly!"
                });
              }
            } else {
              axios.post(`https://${GetParentResourceName()}/Notification`, {
                type: "error",
                msg: "You have to choose your gender!"
              });
            }
          } else {
            axios.post(`https://${GetParentResourceName()}/Notification`, {
              type: "error",
              msg: "You have to choose your country!"
            });
          }
        } else {
          axios.post(`https://${GetParentResourceName()}/Notification`, {
            type: "error",
            msg: "You need to fill your Last Name!"
          });
        }
      } else {
        axios.post(`https://${GetParentResourceName()}/Notification`, {
          type: "error",
          msg: "You need to fill in your name!"
        });
      }
    },
    Selection(data) {
      if (this.select !== data.identifier ) {
        this.select = data.identifier;
        this.onysubs = data;
        this.characterInfo = false;
        self = this;
        setTimeout(function() {
          self.characterInfo = true;
        }, 300)

        axios.post(`https://${GetParentResourceName()}/Select`, {
          id: data.identifier
        });
      }
      
    },
    New() {
      this.addspace = true;
      self = this;
      setTimeout(function() {
        self.addspacee = true;
        self.Delete = true;
        self.disableddelete = true;
        self.onysubs = {};
        self.select = 0;
        self.characterInfo = false;

      }, 300)
      axios.post(`https://${GetParentResourceName()}/PedOrNewCharacter`, {});
    },
    SelectionMenu() {
      if (this.disabledselection === false) {
        this.addspace = false;
        self = this;
        setTimeout(function() {
          self.addspacee = false;
          self.Delete = false;
          self.disableddelete = false;
        }, 300)
        axios.post(`https://${GetParentResourceName()}/PedDelete`, {});
  
      }       
      
    },
    DeleteCharacter() {
      if (this.disableddelete === false) {
        axios.post(`https://${GetParentResourceName()}/DeleteCharacter`, {
          id: this.select
        });
        this.select = 0;
        this.onysubs = {};

      }
    },
    PlayCharacter() {
      axios.post(`https://${GetParentResourceName()}/PlayCharacter`, {});
    }
  },
  mounted () {
    this.fetchData()



    window.addEventListener('message', function (event) {
      var data = event.data;
      switch(data.action) {
          case "setUI":
              ui = data.ui;
              app.translations = data.locales;
              app.nui = ui;
              break;
          case "setupCharacters":
              app.data = {};
              app.data = data.data;
              break;
          case "createCharacters":
              app.data = {};
              app.addspace = true;
              app.addspacee = true;
              app.disableddelete = true;
              app.disabledselection = true;

              break;

      }
    });

  },
});

window.addEventListener("message", function (event) {
  var item = event.data;
  if (item.type == "ui") {
    let data = item.data;
    app.Menu("open", data);
  } else if (item.type == "createui") {
    app.MenuCreate("open");
  } else if (item.type == "exit") {
    app.nui = false;
  }
});
