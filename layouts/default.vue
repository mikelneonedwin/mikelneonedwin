<template>
    <div class="w-full flex items-start">
        <nav @click="toggle" class="bg-[#212121] text-[--theme] material-icons px-2 text-2xl fixed top-2 left-2 rounded-sm">menu</nav>
        <nav @click="toggle" ref="nav" class="lg:w-[17%] sm:w-3/4 sm:hidden sm:z-10 fixed h-screen bg-[#212121] px-4 flex flex-col gap-8">
            <div class="fixed top-0 right-0 w-1/4 bg-black opacity-50 h-full lg:hidden"></div>
            <div class="flex items-center gap-1.5 mt-4">
                <img src="/favicon.ico">
                <p class="text-2xl font-semibold">Winner Edwin</p>
            </div>

            <div>
                <ul class="flex flex-col gap-3">
                    <li><NuxtLink to="/"><i class="material-icons">home</i>Home</NuxtLink></li>
                    <li><NuxtLink to="/about"><i class="material-icons">info</i>About</NuxtLink></li>
                    <li><NuxtLink to="/services"><i class="material-icons">build</i>Services</NuxtLink></li>
                    <li><NuxtLink to="/portfolio"><i class="material-icons">collections</i>Portfolio</NuxtLink></li>
                    <li><NuxtLink to="/contact"><i class="material-icons">mail</i>Contact</NuxtLink></li>
                </ul>
            </div>
        </nav>
        <div>
            <slot/>
        </div>
    </div>
</template>

<script setup>
    const nav = ref(null);
    const toggle = () => nav.value.classList.toggle("sm:hidden");
</script>

<style type="text/tailwindcss">
nav + div {
    @apply lg:w-[83%] lg:ml-auto px-4 lg:flex py-4 sm:overflow-x-hidden;
}
li a {
    @apply flex items-center gap-2 font-semibold;
}
li a i.material-icons {
    @apply text-lg;
}
nav a.router-link-exact-active {
    @apply text-[#00DC82];
}
</style>