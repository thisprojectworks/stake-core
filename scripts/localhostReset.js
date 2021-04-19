async function reset() {
    console.log(
        "Reseting network....",
    );
    await network.provider.request({
        method: "hardhat_reset",
        params: []
    })
}

reset()
    .then(() => {
        console.log('Reset complete.')
        process.exit(0);
    })
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

