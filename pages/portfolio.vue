<template>
    <div>
        <h1 class="title">Portfolio</h1>
        <div>
            <h3 class="font-bold text-2xl">My Last Projects:</h3>
            <div class="grid lg:grid-cols-3 mt-4 sm:grid-cols-1 gap-8">
                <img v-for="img in image" :src="img" :key=img class="rounded-md">
            </div>
        </div>
    </div>
</template>

<script setup>
    const image = Array(6).fill(1).map((a,b) => '/projects/' + (a +b) + '.png');
    const data = [
        {
            title: 'Rest Countries API',
            frameworks: ['React', 'TailwindCSS'],
            description: 'Rest Countries API with dark & light theme developed as party of my thirty days challenge',
            link: 'https://30-smoky.vercel.app/18/',
            img: '/projects/1.png'
        },
        {
            title: ''
        }
    ]
</script>