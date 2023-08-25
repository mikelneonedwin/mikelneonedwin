<template>
    <div class="h-screen items-center justify-center w-full flex">
        <div class="w-11/12 flex items-start gap-4">
            <div class="flex flex-col gap-6 lg:w-3/4 sm:w-full">
                <h2 class="font-bold text-2xl">Hello, my name is <b class="theme">Winner Edwin</b></h2>
                <div class="flex flex-col gap-2">
                    <h1 class="font-bold text-3xl">I'm a <b class="theme" v-html="text"></b><button ref="btn" class="cursor"></button></h1>
                    <p>Seasoned web developer with over 3 years of expertise in Nuxt, Vue, React, Next.js, jQuery, Node.js, Express, Firebase, and deployment through Vercel and GitHub. I thrive on crafting seamless user experiences and solving complex challenges. Let's turn your ideas into exceptional digital realities.</p>
                </div>
                <div class="mt-4">
                    <NuxtLink to="/about">
                        <button class="btn">More About Me</button>
                    </NuxtLink>
                </div>
            </div>
            <div class="w-1/3 sm:hidden text-center">
                <img class="h-[25rem] rounded-lg" src="/me.jpeg">
            </div>
        </div>
    </div>
</template>

<script setup>
    const jobs = ['Web Developer', 'Student', 'Poet', 'Computer Geek'];
    let mode = 'type';
    const text = ref('Web Developer');
    const btn = ref(null);
    async function typeF(i, callback){
        let n = 0;
        text.value = jobs[i][n];
        await new Promise((res, _) => {
            const type = setInterval(() => {
                n++;
                if(n > jobs[i].length){
                    clearInterval(type);
                    return res(true);
                }
                text.value = jobs[i].slice(0,n);
            }, 100)
        })
        await new Promise((res, __) => {
            let count = 0;
            const type = setInterval(() => {
                count++;
                try {
                    if(count % 2) btn.value.classList.add("hidden");
                    else btn.value.classList.remove("hidden");
                } catch {}
                if(count == 2) {
                    clearInterval(type);
                    res(true);
                }
            }, 270)
        })
        await new Promise((res, _) => {
            const type = setInterval(() => {
                n--;
                if(n < 0){
                    clearInterval(type);
                    return res(true);
                }
                text.value = jobs[i].slice(0,n);
            }, 40)
        })
        callback();
    }
    let index = 0;
    const callback = () => {
        index++;
        if(index == jobs.length) index = 0;
        typeF(index, callback);
    };
    typeF(index, callback);
</script>