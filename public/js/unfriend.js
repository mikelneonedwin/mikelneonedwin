/*
  Author: Winner Edwin
  File: unfriend.js
  Description: The code in this file is meant to help facebook users unfriend friends in bulk
  Date: September 5, 2023
*/

/*
* This code isn't guaranteed to always work as it depends on the DOM's structure to function effectively
* This code only runs on Browsers that allow access to the JavaScript console (not readily accessible to mobile users)
* Might not work in all browsers, the code was only tested in Firefox
*/

/* Steps */
/*
* Login in to your facebook account on your browser

* Visit https://www.facebook.com/friends/list

* Access your JavaScript console (how exactly depends on the browser)

* Scroll down as far as you can on your friend's list to load as many friends as possible


* Copy and paste the function below in the console

* Call the function by typing in "unfriend()" and Enter

* The function will get the list of all your friends and use a confirm box to ask if to unfriend the user or leave the user.

* As it continues, it'll log the number of friends left to the console so you know how many users are left for you

* Clicking OK on the confirm box will trigger a set of actions in sequence (i.e. click certain HTML elements on your behalf to unfriend the user)

* Clicking Cancel will move to the next user without doing anything

* Since the function depends on the DOM, it may encouter errors if there's a slight difference or change in the DOM, as such, errors can happen at anytime. How to handle these errors exactly is yet to be solved, hence the function will stop executing

* Based on the speed of your device, the clicks to buttons needs a slight delay to let the button appear on the DOM before it's accessed and clicked. The default is 2 seconds but you can specify yours by placing the number of seconds in between the brackets.
Example: "unfriend(5)" => 5 seconds delay, "unfriend(1)" => 1 second delay
Note: When the delay is too short, errors are bound to happen
 
*/

//Visual Example at https://mikelneonedwin.vercel.app/mp4/unfriend.js.mp4

async function unfriend(delay = 2){
    delay *= 1000;
    const housex = Array.from(document.querySelector("div.x1xmf6yo>div.x135pmgq").children);
    housex.splice(0,3);
    housex.forEach(elem => elem.querySelector("span") ||  housex.splice(housex.indexOf(elem), 1));
    const _names = housex.map(a => a.querySelector("span").textContent);
    const btn = housex.map(a => {
        const btx = a.querySelectorAll(`[role="button"]`); 
        return btx[1] || btx[0];
    });
    for(const i in _names){
        const ni = _names[i];
        await new Promise((res, _) => {
            const ans = confirm("Unfriend " + ni);
            if(ans){
                btn[i].click();
                setTimeout(() => {
                    document.getElementsByClassName("x1i10hfl xjbqb8w x6umtig x1b1mbwd xaqea5y xav7gou xe8uvvx x1hl2dhg xggy1nq x1o1ewxj x3x9cwd x1e5q0jg x13rtm0m x87ps6o x1lku1pv x1a2a7pz xjyslct x9f619 x1ypdohk x78zum5 x1q0g3np x2lah0s xnqzcj9 x1gh759c xdj266r xat24cr x1344otq x1de53dj x1n2onr6 x16tdsg8 x1ja2u2z x6s0dn4 x1y1aw1k xwib8y2")[3].click();
                    setTimeout(() => {
                        document.querySelector('div.xl9nvqe:nth-child(1) > div:nth-child(1)').click();
                        setTimeout(() => res(true), delay);
                    }, delay)
                }, delay)
            } else res(true);
        })
        console.log(_names.length - i, "left");
    }
}