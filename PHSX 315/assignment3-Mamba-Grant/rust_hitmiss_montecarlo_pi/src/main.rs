#![allow(dead_code)]
#![allow(unused_variables)]
#![allow(non_snake_case)]

use argparse::{ArgumentParser, Store, StoreTrue};
use plotters::prelude::*;
use rand::{distributions::Uniform, SeedableRng};
use rand_distr::Distribution;
use rand_pcg::Pcg32;
use std::time::Instant;

const PI: f64 = 3.1415926535897932384626433832795028841971693993751058209749445923;
const POINTSCALE: f64 = 2f64;
const DIMENSIONS: (u32, u32) = (600, 600);
const OUT_FILE_NAME: &'static str = "3d-plot2.gif";

fn plot(dataset: Vec<(f64, f64, f64)>) -> Result<(), Box<dyn std::error::Error>> {
    println!("Compiling plot ...");
    let root = BitMapBackend::gif(OUT_FILE_NAME, DIMENSIONS, 100)?.into_drawing_area();

    Ok(for pitch in 0..157 {
        root.fill(&WHITE)?;

        let mut chart = ChartBuilder::on(&root)
            .caption("Hit and Miss Monte Carlo - PI", ("sans-serif", 20))
            .build_cartesian_3d(-1.0..1.0, -1.0..1.0, -1.0..1.0)?;
        chart.with_projection(|mut p| {
            p.pitch = 1.57 - (1.57 - pitch as f64 / 50.0).abs();
            p.scale = 0.7;
            p.into_matrix() // build the projection matrix
        });

        chart
            .configure_axes()
            .light_grid_style(BLACK.mix(0.15))
            .max_light_lines(3)
            .draw()?;

        chart.draw_series(dataset.iter().map(|(x, y, z)| {
            match f64::sqrt(f64::powi(*x, 2) + f64::powi(*y, 2) + f64::powi(*z, 2)) > 1f64 {
                true => Circle::new((*x, *y, *z), 4f64, RED),

                false => Circle::new((*x, *y, *z), 4f64, GREEN.filled()),
            }
        }))?;

        // To avoid the IO failure being ignored silently, we manually call the present function
        root.present().expect("Unable to write result to file, please make sure 'plotters-doc-data' dir exists under current dir");
    })
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut _plot: bool = false;
    let mut _iterations: usize = 1000;
    let mut _seed: u64 = 42;
    {
        // this block limits scope of borrows by ap.refer() method
        let mut ap = ArgumentParser::new();
        ap.set_description("Calculates PI in 3D using Hit and Miss Monte Carlo Integration.");
        ap.refer(&mut _iterations)
            .add_option(&["-i", "--iterations"], Store, "Iteration Count");
        ap.refer(&mut _seed)
            .add_option(&["-s", "--seed"], Store, "Random Seed");
        ap.refer(&mut _plot)
            .add_option(&["-p", "--plot"], StoreTrue, "Plot Graph");
        ap.parse_args_or_exit();
    }

    let before = Instant::now();

    let between = Uniform::from(-1f64..1f64);
    let mut rng = Pcg32::seed_from_u64(_seed);

    let mut random_points: Vec<(f64, f64, f64)> = Vec::with_capacity(_iterations);
    for i in 0..random_points.capacity() {
        random_points.push((
            between.sample(&mut rng),
            between.sample(&mut rng),
            between.sample(&mut rng),
        ));
    }

    let radius: Vec<f64> = {
        random_points
            .iter()
            .map(|(x, y, z)| f64::sqrt(f64::powi(*x, 2) + f64::powi(*y, 2) + f64::powi(*z, 2)))
            .rev()
            .collect()
    };

    let oob: Vec<bool> = { radius.iter().map(|r| r > &1f64).rev().collect() };

    let inside = oob.iter().filter(|x| x != &&true).count();

    let percent = inside as f64 / _iterations as f64;
    let calculated_pi = 6f64 * percent;
    let err = 6f64 * f64::sqrt((calculated_pi / 6f64) * (1f64 - (calculated_pi / 6f64)))
        / f64::sqrt(_iterations as f64);
    let pd = (calculated_pi - PI).abs() / ((calculated_pi + PI) / 2f64);

    // Output
    println!("Running with {} Samples:", _iterations);
    println!("Elapsed time (calculation): {:.2?}", before.elapsed());
    println!(" Pi is approximately equal to: {}", calculated_pi);
    println!(
        " There were [{}] points inside the sphere [{}%].",
        inside, percent*10f64
    );
    println!(" Standard Deviation: {}\n Diff %: {}", err, pd);

    if _plot == true {
        plot(random_points)?;
    }

    println!("Done!\nElapsed time (total): {:.2?}", before.elapsed());

    Ok(())
}
