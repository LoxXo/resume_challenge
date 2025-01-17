function showVisitors() {
    fetch('https://func-http-trigger-resume.azurewebsites.net/api/new_visitor?')
        .then(function (response) { return response.text(); })
        .then(function (text) {
            document.getElementById("visitors").innerHTML = text;
         })
        .catch(() => {
            document.getElementById("visitors").innerHTML = "Error";
        });
}
window.onload = showVisitors()