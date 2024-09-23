var data
window.onload = function showVisitors(){
    fetch('https://http-trigger-cosmos-resume.azurewebsites.net/api/new_visitor?')
    .then(response => console.log(response.status) || response)
    .then(response => (data = response.text()))
    document.getElementById("visitors").innerHTML = data;
}