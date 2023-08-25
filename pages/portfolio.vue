<template>
    <div>
        <h1 class="title">Portfolio</h1>
        <div>
            <h3 class="font-bold text-2xl">My Last Projects:</h3>
            <div class="grid lg:grid-cols-3 mt-4 sm:grid-cols-1 gap-8">
                <div v-for="item in data" :key="item.img" class="flex flex-col items-start gap-4 p-4 rounded-xl bg-[#212121]">
                    <img :src="item.img" class="rounded-md w-full">
                    <div class="flex flex-col gap-2">
                        <h1 class="font-bold text-lg">{{ item.title }}</h1>
                        <div v-if="item.frameworks" class="text-left text-[--theme] font-semibold text-sm mr-1 rounded-lg">{{ item.frameworks.join(' & ') }}</div>
                        <p class="text-sm opacity-70">{{ item.description }}</p>
                        <a :href="item.link" class="mt-1">
                            <button class="py-0.5 text-sm mr-1 px-4 rounded-lg bg-[--theme]">Visit</button>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
    const data = [
        {
            title: 'Rest Countries API',
            frameworks: ['React.js', 'TailwindCSS'],
            description: 'Rest Countries API with dark & light theme developed as part of my thirty days challenge',
            link: 'https://30-smoky.vercel.app/18/',
            img: '/projects/1.png'
        },
        {
            title: 'Easybank Landing Page',
            frameworks: ['TailwindCSS'],
            description: 'Landing page for Easybank',
            link: 'https://30-smoky.vercel.app/6/',
            img: '/projects/2.png'
        },
        {
            title: 'Crowdfunding Project Page',
            frameworks: ['TailwindCSS'],
            description: 'Developed as part of my thirty days challenge',
            img: '/projects/3.png',
            link: 'https://30-smoky.vercel.app/5/',
        },
        {
            title: 'Bookmark Landing Page',
            frameworks: ['React.js'],
            description: 'Landing page for a bookmark\'s website',
            img: '/projects/4.png',
            link: 'https://30-smoky.vercel.app/3/',
        },
        {
            title: 'Blogr Landing Page',
            description: 'Blogr Landing page for a blog website',
            img: '/projects/5.png',
            link: 'https://30-smoky.vercel.app/2/',
            frameworks: ['HTML', 'CSS']
        },
        {
            title: 'URL Shortener',
            description: 'Landing page for a link shortening website',
            frameworks: ['Vue.js', 'TailwindCSS'],
            img: '/projects/6.png',
            link: 'https://30-smoky.vercel.app/27/',
        },
        {
            title: 'Todo App',
            description: 'Todo app created for the thirty days coding challenge',
            frameworks: ['Vue.js', 'TailwindCSS'],
            img: '/projects/7.png',
            link: 'https://30-smoky.vercel.app/26/',
        }
    ]
</script>