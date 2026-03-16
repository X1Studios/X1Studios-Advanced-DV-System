window.addEventListener("message", function(event){

    const box = document.getElementById("notify")

    if(event.data.type === "notify"){

        box.innerHTML = event.data.text
        box.style.display = "block"

        setTimeout(function(){
            box.style.display = "none"
        },4000)

    }

    if(event.data.type === "wipeStart"){
        box.style.display = "block"
        box.innerHTML = "Vehicle Wipe Starting..."
    }

    if(event.data.type === "wipeUpdate"){
        box.innerHTML = "Vehicle Wipe In Progress<br>Vehicles Removed: " + event.data.count
    }

    if(event.data.type === "wipeEnd"){
        box.innerHTML = "Vehicle Wipe Complete<br>Total Removed: " + event.data.total

        setTimeout(function(){
            box.style.display = "none"
        },5000)
    }

})