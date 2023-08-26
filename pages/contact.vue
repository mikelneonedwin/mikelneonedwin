<template>
    <div class="w-full">
        <h1 class="title">Contact Me</h1>
        <div class="flex flex-col gap-4 items-center justify-center w-full">
            <h2 class="text-center text-3xl text-[--theme] font-bold">Got Any Questions?</h2>
            <p class="font-bold">I'M AT YOUR SERVICE</p>
            <div class="grid lg:grid-cols-2 lg:w-3/4 sm:grid-cols-1 w-full gap-6 mt-8">
                <a class="cardx" href="tel:2348076488738">
                    <i class="material-icons">phone</i>
                    <h3>Call</h3>
                    <p>+234 807 6488 738</p>
                </a>
                <div class="cardx">
                    <i class="material-icons">location_on</i>
                    <h3>Address</h3>
                    <p>2b Akwa Ekpene Close, Uyo</p>
                </div>
                <a class="cardx" href="maiilto:mynameiswinneredwin@gmail.com">
                    <i class="material-icons">mail</i>
                    <h3>Email</h3>
                    <p>mynameiswinneredwin@gmail.com</p>
                </a>
                <a class="cardx" href="https://mikelneonedwin.vercel.app">
                    <i class="material-icons">public</i>
                    <h3>Website</h3>
                    <p>https://mikelneonedwin.vercel.app</p>
                </a>
            </div>
            <div class="flex items-center justify-center mb-8 gap-16">
                <a href="https://fb.me/mikelneonedwin" target="_blank">
                    <img src="/svg/facebook.svg">
                </a>
                <a href="https://wa.me/2348076488738" target="_blank">
                    <img src="/svg/whatsapp.svg">
                </a>
                <a href="https://github.com/mikelneonedwin" target="_blank">
                    <img src="/svg/github.svg">
                </a>
                <a href="https://m.me/mikelneonedwin" target="_blank">
                    <img src="/svg/facebook-messenger.svg">
                </a>
            </div>
        </div>
    </div>
</template>

<style>
@tailwind components;
@layer components {
    .cardx {
        @apply rounded-lg p-6 flex items-center justify-center flex-col gap-2;
    }
}
.cardx i {
    @apply text-[--theme] mb-3 text-7xl font-bold;
}
.cardx h3 {
    @apply font-bold text-2xl;
}
.cardx p {
    @apply text-center;
}
nav+div {
    @apply sm:w-full;
}
div a img {
    @apply h-8;
}
</style>