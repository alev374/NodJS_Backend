function resolver(x) {
  return new Promise(resolve => {
    setTimeout(() => {
      resolve(x);
    }, 300);
  });
}


async function add1(x) {
  const a = await resolver(20);
  const b = await resolver(30);
  return x + a + b;
}

add1(10).then(v => {
  console.log(v);
});