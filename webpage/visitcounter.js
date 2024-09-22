window.onload = function(){
    fetch('https://http-trigger-cosmos-resume.azurewebsites.net/api/new_visitor?')
    .then(data => {
    return data;
    })
    .then(post => {
    console.log(post);
    });
    data = 'bardzo fajne zdanie'
    document.getElementById("visitors") = data;
}