import { loadStdlib } from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';
const stdlib = loadStdlib();

const startingBalance = stdlib.parseCurrency(100);
const accCreator = await stdlib.newTestAccount(startingBalance);
const accOwner = await stdlib.newTestAccount(startingBalance);
//Creator opens contract Owner joins
const ctcCreator = accCreator.contract(backend);
const ctcOwner = accOwner.contract(backend, ctcCreator.getInfo());

await Promise.all([
    ctcCreator.p.Creator({
        //Implement Creator's interact object
    }),
    ctcOwner.p.Owner({
        //implement Owner's interact object
    }),
]);